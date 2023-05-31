function [] = WriteImageToTIFF(seq_read,Path_to_save,gene,RNA_label,name)
cd(Path_to_save);
seq_read = single(seq_read);

if exist(gene) == 7
    cd(gene)
else
    mkdir(gene)
    cd(gene)
end

if exist(string(RNA_label)) == 7
    cd(string(RNA_label))
else
    mkdir(string(RNA_label));
    cd(string(RNA_label));
end

fileName = name + ".tif";
tiffObject = Tiff(fileName, 'w');
% Set tags.
tagstruct.ImageLength = size(seq_read,1); 
tagstruct.ImageWidth = size(seq_read,2);
tagstruct.Compression = Tiff.Compression.None;
tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 32;
tagstruct.SamplesPerPixel = size(seq_read,3);
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tiffObject.setTag(tagstruct);
% Write the array to disk.
tiffObject.write(seq_read);
tiffObject.close;
end
