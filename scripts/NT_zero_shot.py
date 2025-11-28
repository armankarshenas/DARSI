import os
import numpy as np
import pandas as pd
import torch
from transformers import AutoTokenizer, AutoModelForMaskedLM
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
import matplotlib.pyplot as plt
from tqdm import tqdm

# ----------------------------
# CONFIG
# ----------------------------
TRAIN_PATH = "Train_activity.txt"
VAL_PATH   = "Valid_activity.txt"
TEST_PATH  = "Test_activity.txt"

SEQ_COL   = "sequence"
LABEL_COL = "label_RNA_DNA"
GENE_COL  = "gene"

# Smaller & faster NT v2 model (better for Colab)
MODEL_NAME = "InstaDeepAI/nucleotide-transformer-v2-50m-multi-species"
MAX_LEN    = 160          
BATCH_SIZE = 32           

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
use_amp = torch.cuda.is_available()
print("Using device:", device)
print("torch version:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))



# ----------------------------
# LOAD DATA
# ----------------------------
train_df = pd.read_csv(TRAIN_PATH, sep=",")
val_df   = pd.read_csv(VAL_PATH,   sep=",")
test_df  = pd.read_csv(TEST_PATH,  sep=",")

train_df = train_df[[SEQ_COL, LABEL_COL, GENE_COL]].copy()
val_df   = val_df[[SEQ_COL, LABEL_COL, GENE_COL]].copy()
test_df  = test_df[[SEQ_COL, LABEL_COL, GENE_COL]].copy()

print("Train size:", len(train_df), "Val size:", len(val_df), "Test size:", len(test_df))

# ----------------------------
# LOAD MODEL
# ----------------------------
print("Loading tokenizer & model:", MODEL_NAME)
tokenizer = AutoTokenizer.from_pretrained(
    MODEL_NAME,
    trust_remote_code=True
)
model = AutoModelForMaskedLM.from_pretrained(
    MODEL_NAME,
    trust_remote_code=True
)
model.to(device)
model.eval()
print("Model loaded.")

# ----------------------------
# EMBEDDING FUNCTIONS
# ----------------------------
@torch.inference_mode()
def embed_sequences_batch(seqs):
    """
    Embed a batch of sequences with Nucleotide Transformer (mean-pooled).
    Returns numpy array of shape [B, H].
    """
    enc = tokenizer(
        list(seqs),
        padding="max_length",
        truncation=True,
        max_length=MAX_LEN,
        return_tensors="pt",
    )
    enc = {k: v.to(device) for k, v in enc.items()}  # input_ids, attention_mask, ...

    if use_amp:
        with torch.autocast(device_type="cuda", dtype=torch.bfloat16):
            outputs = model(
                **enc,
                encoder_attention_mask=enc["attention_mask"],
                output_hidden_states=True,
            )
    else:
        outputs = model(
            **enc,
            encoder_attention_mask=enc["attention_mask"],
            output_hidden_states=True,
        )

    hidden = outputs.hidden_states[-1]                # [B, L, H]
    mask = enc["attention_mask"].unsqueeze(-1)        # [B, L, 1]

    summed = (hidden * mask).sum(dim=1)               # [B, H]
    counts = mask.sum(dim=1)                          # [B, 1]
    emb = (summed / counts).cpu().float().numpy()     # [B, H]

    return emb


def embed_dataframe(df_subset, seq_col=SEQ_COL, batch_size=BATCH_SIZE):
    """
    Embed all sequences in a *subset* DataFrame for a single gene, in batches.
    Returns numpy array [N_gene, H], aligned with df_subset.index.
    """
    seqs = df_subset[seq_col].tolist()
    all_emb = []
    n = len(seqs)
    if n == 0:
        return np.empty((0, 0))

    for start in range(0, n, batch_size):
        end = min(start + batch_size, n)
        batch = seqs[start:end]
        emb_batch = embed_sequences_batch(batch)
        all_emb.append(emb_batch)

    return np.vstack(all_emb)

# Tiny sanity check on a handful of sequences (to catch any API issues early)
print("Testing tiny batch...")
tiny_emb = embed_sequences_batch(train_df[SEQ_COL].iloc[:4])
print("Tiny batch embedding shape:", tiny_emb.shape)

# ----------------------------
# PER-GENE TRAINING & EVAL (STREAMING, LOW MEMORY)
# ----------------------------
genes = sorted(train_df[GENE_COL].unique().tolist())
results = []

print("\nProcessing genes one by one...")
for gene in tqdm(genes):
    # slice each split for this gene
    train_g = train_df[train_df[GENE_COL] == gene]
    val_g   = val_df[val_df[GENE_COL]   == gene]
    test_g  = test_df[test_df[GENE_COL] == gene]

    n_train = len(train_g)
    n_val   = len(val_g)
    n_test  = len(test_g)

    if n_train < 5:
        # not enough samples to train a meaningful classifier
        # you can adjust this threshold if you want
        continue

    # Labels
    y_train = train_g[LABEL_COL].values
    y_val   = val_g[LABEL_COL].values if n_val > 0 else np.array([])
    y_test  = test_g[LABEL_COL].values if n_test > 0 else np.array([])

    # --- Embed ONLY sequences for this gene ---
    print(f"\nGene {gene}: embedding "
          f"n_train={n_train}, n_val={n_val}, n_test={n_test}")

    X_train = embed_dataframe(train_g)
    X_val   = embed_dataframe(val_g)  if n_val  > 0 else np.empty((0, X_train.shape[1]))
    X_test  = embed_dataframe(test_g) if n_test > 0 else np.empty((0, X_train.shape[1]))

    # --- Train classifier for this gene ---
    clf = LogisticRegression(
        max_iter=2000,
        multi_class="auto",
        class_weight="balanced",
        n_jobs=-1,
    )
    clf.fit(X_train, y_train)

    # --- Accuracies ---
    train_acc = accuracy_score(y_train, clf.predict(X_train))

    if n_val > 0:
        val_acc = accuracy_score(y_val, clf.predict(X_val))
    else:
        val_acc = np.nan

    if n_test > 0:
        test_acc = accuracy_score(y_test, clf.predict(X_test))
    else:
        test_acc = np.nan

    print(f"Gene {gene:<12}  Train={train_acc:.3f} | Val={val_acc:.3f} | Test={test_acc:.3f}")

    results.append({
        "gene": gene,
        "train_acc": train_acc,
        "val_acc": val_acc,
        "test_acc": test_acc,
        "n_train": n_train,
        "n_val": n_val,
        "n_test": n_test,
    })

    # --- Free memory for this gene ---
    del X_train, X_val, X_test, clf
    torch.cuda.empty_cache()

# ----------------------------
# RESULTS + PLOT
# ----------------------------
results_df = pd.DataFrame(results)
print("\nPer-gene results:")
print(results_df)
results_df.to_csv("NucleotideTransformer.csv")
if not results_df.empty:
    genes_plot = results_df["gene"].tolist()
    x = np.arange(len(genes_plot))
    width = 0.25

    plt.figure(figsize=(max(10, len(genes_plot) * 0.5), 6))
    plt.bar(x - width, results_df["train_acc"].values, width, label="Train")
    plt.bar(x,         results_df["val_acc"].values,   width, label="Val")
    plt.bar(x + width, results_df["test_acc"].values,  width, label="Test")

    plt.xticks(x, genes_plot, rotation=45, ha="right")
    plt.ylim(0, 1.0)
    plt.ylabel("Accuracy")
    plt.title("Per-gene multi-class accuracy using NT v2-50m embeddings (streaming)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("nt_v2_50m_per_gene_accuracy_streaming.png", dpi=300)
    plt.show()
else:
    print("No genes with sufficient data to plot.")
