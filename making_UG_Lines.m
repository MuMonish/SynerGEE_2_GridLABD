
function [conf_UG_name,conf_UG_phases]=making_UG_Lines(FeederName,glm_dir_name,SecFromTo,UG_line,Type_UG)
%load(strcat(FeederName,'_Feeder_Lines_UG.mat'));
%load(strcat(FeederName,'_SectionFromTo.mat'));

To_node_RFS=SecFromTo(:,5);
[~,indices]=sort(To_node_RFS);
ordered_SecFromTo=SecFromTo(indices,:);
secfromregfuseswitch=ordered_SecFromTo(:,1);
sec_UG=UG_line(:,1);
[UG,~]=ismember(sec_UG,secfromregfuseswitch);
k=1;
j=1;
sw_fuse_reg_indices=[];
for i=1:length(UG)
    if (UG(i)==0)
        UG_indices(k,1)=i;
        k=k+1;
    else
        sw_fuse_reg_indices(j,1)=i;
        j=j+1;
    end
    
end

%%
[~,secID]=unique(secfromregfuseswitch);
sec_f_reg_sw_info=ordered_SecFromTo(secID,:);

GlmFileName=strcat(glm_dir_name,'\','UndergroundLines_',FeederName,'.glm');
fid = fopen(GlmFileName,'wt');
fprintf(fid,strcat('//**Underground Lines for ',FeederName,':%s\n\n\n'),'');


conf_UG_type_phases=cell(1,1);
Type_UG_int = cell2mat(Type_UG(:,1));
Type_UG_neutral_int=cell2mat(Type_UG(:,2));
Type_UG_phase_int=cell2mat(Type_UG(:,1));
Length_UG = cell2mat(UG_line(:,16));
k=1;
for i = 1:size(UG_line,1)
    fprintf(fid,'object underground_line {\n');
    fprintf(fid,'\t name %s;\n',char(UG_line(i,1)));
    fprintf(fid,'\t phases %s;\n',strrep(char(UG_line(i,5)),' ',''));
    if (ismember(i,sw_fuse_reg_indices)==0)
        fprintf(fid,'\t from %s;\n',char(UG_line(i,3)));
    else
        for t=1:length (sec_f_reg_sw_info(:,1))
            if strcmp(cellstr(UG_line(i,1)),cellstr(sec_f_reg_sw_info(t,1)))
                ind=t;
            end
        end
        fprintf(fid,'\t from %s;\n',char(sec_f_reg_sw_info(ind,5)));
    end
    fprintf(fid,'\t to %s;\n',char(UG_line(i,4)));
    if Length_UG(i)>0
        fprintf(fid,'\t length %f;\n',Length_UG(i));
    else
        fprintf(fid,'\t length %f;\n',10);
    end
    
    conf_UG_type_phases(k,1)=cellstr(UG_line(i,5));
    conf_UG_neutral(k,1)=Type_UG_neutral_int(i,1);
    conf_UG_phases(k,1)=Type_UG_phase_int(i,1);
    conf_UG_name(k,1)=strcat(conf_UG_type_phases(k,1),'_',int2str(conf_UG_neutral(k,1)),'_',int2str(conf_UG_phases(k,1)),'_',FeederName);
    fprintf(fid,'\t configuration underground_line_config_%s;\n',char(conf_UG_name(k,1)));
    k=k+1;
    fprintf(fid,'\t } \n\n');
    
end

%save (strcat(FeederName,'_Feeder_UG_lines'),'conf_UG_name','conf_UG_phases')
end