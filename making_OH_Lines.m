
function [conf_OH_name,conf_OH_phases]=making_OH_Lines(FeederName,glm_dir_name,SecFromTo,OH_line,Type_OH)
%load(strcat(FeederName,'_Feeder_Lines_OH.mat'));
%load(strcat(FeederName,'_SectionFromTo.mat'));

ordered_SecFromTo=SecFromTo;

secfromregfuseswitch=ordered_SecFromTo(:,1);
sec_OH=OH_line(:,1);

[OH,~]=ismember(sec_OH,secfromregfuseswitch);

k=1;
j=1;
for i=1:length(OH)
    if (OH(i)==0)
        OH_indices(k,1)=i;
        k=k+1;
    else
        sw_fuse_reg_indices(j,1)=i;
        j=j+1;
    end
    
end

%%
[~,secID]=unique(secfromregfuseswitch);
sec_f_reg_sw_info=ordered_SecFromTo(secID,:);

GlmFileName=strcat(glm_dir_name,'\','OverheadLines_',FeederName,'.glm');
fid = fopen(GlmFileName,'wt');
fprintf(fid,strcat('//**Overhead Lines for ',FeederName,':%s\n\n\n'),'');


conf_OH_type_phases=cell(1,1);
%Type_OH_int = cell2mat(Type_OH(:,1));
Type_OH_neutral_int=cell2mat(Type_OH(:,2));
Type_OH_phase_int=cell2mat(Type_OH(:,1));
Length_OH = cell2mat(OH_line(:,16));
k=1;
for i = 1:size(OH_line,1)
    fprintf(fid,'object overhead_line {\n');
    fprintf(fid,'\t name %s;\n',char(OH_line(i,1)));
    fprintf(fid,'\t phases %s;\n',strrep(char(OH_line(i,5)),' ',''));
    if (ismember(i,sw_fuse_reg_indices)==0)
        fprintf(fid,'\t from %s;\n',char(OH_line(i,3)));
    else
        for t=1:length (sec_f_reg_sw_info(:,1))
            if strcmp(cellstr(OH_line(i,1)),cellstr(sec_f_reg_sw_info(t,1)))
                ind=t;
            end
        end
        fprintf(fid,'\t from %s;\n',char(sec_f_reg_sw_info(ind,5)));
    end
    fprintf(fid,'\t to %s;\n',char(OH_line(i,4)));
    if Length_OH(i)>0
        fprintf(fid,'\t length %f;\n',Length_OH(i));
    else
        fprintf(fid,'\t length %f;\n',10);
    end
    
    conf_OH_type_phases(k,1)=cellstr(OH_line(i,5));
    conf_OH_neutral(k,1)=Type_OH_neutral_int(i,1);
    conf_OH_phases(k,1)=Type_OH_phase_int(i,1);
    conf_OH_name(k,1)=strcat(conf_OH_type_phases(k,1),'_',int2str(conf_OH_neutral(k,1)),'_',int2str(conf_OH_phases(k,1)),'_',FeederName);
    fprintf(fid,'\t configuration overhead_line_config_%s;\n',char(conf_OH_name(k,1)));
    k=k+1;
    fprintf(fid,'\t } \n\n');
    
end

%save (strcat(FeederName,'_Feeder_OH_lines'),'conf_OH_name','conf_OH_phases')
end