%% Open the files

%Var1: index
%ct_RNA
%barcode
%ct_DNA
%sequence
%gene
%nmut: number of mutations
%Header: label combining gene name and barcode
%ctr: ratio of RNA to DNA
%label_RNA_DNA: the expression bin for the DARSI clarification (-1/0/1)
Path_to_data = '/Users/arman/Desktop/DARSI/';
Path_to_save = '/Users/arman/Desktop/DARSI/new_run_plots/MutualInfo';

cd(Path_to_data)
%Load all tables
TestData=readtable('Test_activity.txt');
ValidData=readtable('Valid_activity.txt');
TrainData=readtable('Train_activity.txt');

%Concatenate all tables
Data=vertcat(TestData,ValidData,TrainData);


%% Look at the araAB gene

%Get all the araAB information from the data
%Some genes to look at: zapB, rspA, ykgE

Genes = unique(Data.gene);

for j=1:length(Genes)
    waitbar(j/length(Genes))
    GeneToLookAt=Genes{j};

    DataGene=Data(string(Data.gene)==GeneToLookAt,:);

    %Define the wild-type as the consensus sequence - Note that we're not
    %really invoking the wild-type sequence
    WT = seqconsensus(DataGene.sequence);


    %Put together all sequences in an easier structure
    Seq = char(string(DataGene.sequence));


    %Get pexp:
    %pexp(0)
    pexp0=sum(DataGene.ct_DNA)/(sum(DataGene.ct_DNA)+sum(DataGene.ct_RNA));
    %pexp(1)
    pexp1=sum(DataGene.ct_RNA)/(sum(DataGene.ct_DNA)+sum(DataGene.ct_RNA));


    %Get the mean expression level. First, we calculate the ratio of RNA to
    %DNA. Note that sometimes there won't be an RNA read and sometimes
    %there won't be a DNA read.
    %For TOM: should we have removed those from the data set altogether?
    ctValues=(DataGene.ct_RNA)./(DataGene.ct_DNA);
    ctValues=ctValues(ctValues>0);
    ctValues=ctValues(~isinf(ctValues));
    MeanctValues=mean(ctValues);


    %Calculate the mutual information at each position
    for i=1:length(WT)

        %Count wild-type bases at position i
        nWT=sum(Seq(:,i)==WT(i));
        %pmut(0)
        pmut0=(sum(DataGene(Seq(:,i)==WT(i),:).ct_DNA)+...
            sum(DataGene(Seq(:,i)==WT(i),:).ct_RNA))/...
            (sum(DataGene.ct_DNA)+...
            sum(DataGene.ct_RNA));

        %pmut(1)
        pmut1=(sum(DataGene(Seq(:,i)~=WT(i),:).ct_DNA)+...
            sum(DataGene(Seq(:,i)~=WT(i),:).ct_RNA))/...
            (sum(DataGene.ct_DNA)+...
            sum(DataGene.ct_RNA));


        %p(0,0), wild-type base, DNA
        p00=sum(DataGene(Seq(:,i)==WT(i),:).ct_DNA)/...
            (sum(DataGene.ct_DNA)+...
            sum(DataGene.ct_RNA));

        %p(0,1), wild-type base, RNA
        p01=sum(DataGene(Seq(:,i)==WT(i),:).ct_RNA)/...
            (sum(DataGene.ct_DNA)+...
            sum(DataGene.ct_RNA));

        %p(1,0), mutated base, DNA
        p10=sum(DataGene(Seq(:,i)~=WT(i),:).ct_DNA)/...
            (sum(DataGene.ct_DNA)+...
            sum(DataGene.ct_RNA));

        %p(1,1), mutated base, RNA
        p11=sum(DataGene(Seq(:,i)~=WT(i),:).ct_RNA)/...
            (sum(DataGene.ct_DNA)+...
            sum(DataGene.ct_RNA));

        MI(i)=p00 * log2(p00/(pmut0*pexp0)) + p01 * log2(p01/(pmut0*pexp1)) +...
            p10 * log2(p10/(pmut1*pexp0)) + p11 * log2(p11/(pmut1*pexp1));

        %Determine which bars are blue and red. We're using the expression
        %shift as defined in equation 9 of Pan2024.
        ctValuesMut=DataGene(Seq(:,i)~=WT(i),:).ct_RNA./...
            (DataGene(Seq(:,i)~=WT(i),:).ct_DNA);
        ctValuesMut=ctValuesMut(ctValuesMut>0);
        ctValuesMut=ctValuesMut(~isinf(ctValuesMut));

        ExpressionShift(i)=mean(ctValuesMut-MeanctValues);

    end


    %Create the moving average
    MI=movmean(MI,5);
    %ExpressionSxhift=movmean(ExpressionShift,5);

    cd(Path_to_save)
    mkdir(GeneToLookAt)
    cd(GeneToLookAt)

    %Plot regardless of expression shift sign
    BinRange=1:length(WT);
    figure(1)
    bar(BinRange,MI)
    
    name = GeneToLookAt+"_unsigned_mutual_information";
    saveas(gcf,name+".eps","epsc")
    saveas(gcf,name+".png")
    close 
    %Account for expression shift sign
    figure(2)
    bar(BinRange,ExpressionShift)

    FilterPositiveShift = ExpressionShift>0;
    FilterNegativeShift = ExpressionShift<0;

    close
    figure(3)
    bar(BinRange(FilterPositiveShift),MI(FilterPositiveShift),'red')
    hold on
    bar(BinRange(FilterNegativeShift),MI(FilterNegativeShift),'blue')
    hold off
    name = GeneToLookAt+"_signed_mutual_information";
    saveas(gcf,name+".eps","epsc")
    saveas(gcf,name+".png")
    close 
end

