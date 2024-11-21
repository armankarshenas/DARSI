function binding_sites_sensitivity_analysis(Path_to_data,Path_to_save)
% binding_sites_sensitivity_analysis varies the two parameters used to
% filet out expression patter: 1) Motif length and 2) Peak Threshold 

% Written by A. Karshenas -- Feb 27, 2024
%----------------------------------------------------
addpath(genpath("/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/Reg-seq/Matlab/"))
cd(Path_to_data)

genes = dir(pwd);
L = [6 8 10 12 14];
th = [0.25 0.5 1 1.5 2];
CBS = struct();
CBS.count = zeros([1,length(L)*length(th)]);
str_counter=1;
for l=1:length(L)
    for t=1:length(th)
        for i=3:length(genes)
            if genes(i).isdir == 1
                cd(Path_to_data)
                cd(genes(i).name)
                load("SalientMapData.mat","SalientMaps");
                A = SalientMaps(2).Map;
                b = max(A);
                normalized_b = (b-mean(b))/std(b);
                exp_b = exp(abs(normalized_b));
                idx_pos = normalized_b >=0;
                idx_neg = normalized_b <0;
                exp_b_pos = exp_b.*double(idx_pos);
                exp_b_neg = exp_b.*double(idx_neg);
                threshold_bs = mean(exp_b)+std(exp_b);
                idx = exp_b >= th(t)*threshold_bs;
                filtered_b = double(idx).*exp_b;
                b_sign_filt_f = zeros([1,160]);
                for j=1:160
                    if idx(j) == 1
                        flag = true;
                        counter = 1;
                        while flag == true && counter+j<=160
                            if normalized_b(j+counter)*normalized_b(j+counter-1)<0 || j+counter==160
                                flag = false;
                                if counter >=L(l) || j+counter==160
                                    b_sign_filt_f(j:j+counter-1) = exp_b(j:j+counter-1);
                                end
                            else
                                counter = counter+1;
                            end
                        end
                    end
                end
                b_sign_filt_r = zeros([1,160]);
                for j=1:160
                    if idx(j) == 1
                        flag = true;
                        counter = 1;
                        while flag == true && counter+j<=160
                            if normalized_b(j+counter)*normalized_b(j+counter-1)<0 || j+counter==160
                                flag = false;
                                if counter >=L(l) || j+counter==160
                                    b_sign_filt_r(j:j+counter-1) = exp_b(j:j+counter-1);
                                end
                            else
                                counter = counter+1;
                            end
                        end
                    end
                end
                b_sign_filt = [b_sign_filt_f;b_sign_filt_r];
                b_sign_filt = max(b_sign_filt);
                boolian_b = b_sign_filt >0;
                derivative_b = diff(double(boolian_b));
                num_BS = derivative_b ==1;
                num_BS = sum(double(num_BS));
                if sum(derivative_b) ~= 0 
                    num_BS = num_BS + 1;
                end
                
                CBS.count(str_counter) = CBS.count(str_counter) + num_BS;
                
            end
        end
        
        CBS.L(str_counter) = L(l);
        CBS.Th(str_counter) = th(t);
        str_counter = str_counter +1;
    end
    cd(Path_to_save)
    
end
save("sensitivity_analysis.mat",'CBS');
end