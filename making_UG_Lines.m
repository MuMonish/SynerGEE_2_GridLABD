

function Make_UG_Lines=making_UG_Lines(dir_name,FeederName,glm_dir_name)

%load('Feeder_Lines_UG.mat');
%load('SectionFromTo.mat');
load(strcat(FeederName,'_Feeder_Lines_UG.mat'));
load(strcat(FeederName,'_SectionFromTo.mat'));


To_node_RFS=SecFromTo(:,5);
[ordered,indices]=sort(To_node_RFS);
ordered_SecFromTo=SecFromTo(indices,:);

secfromregfuseswitch=ordered_SecFromTo(:,1);
sec_UG=UG_line(:,1);

[UG,indices_UG]=ismember(sec_UG,secfromregfuseswitch);

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
[unique_sec_F_Reg_Sw,secID]=unique(secfromregfuseswitch);
sec_f_reg_sw_info=ordered_SecFromTo(secID,:);

GlmFileName=strcat(glm_dir_name,'\','UndergroundLines_',FeederName,'.glm')
fid = fopen(GlmFileName,'wt');
fprintf(fid,strcat('//**Underground Lines for ',FeederName,':%s\n\n\n'),'');


conf_UG_type_phases=cell(1,1);
Type_UG_int = cell2mat(Type_UG_phase);
Type_UG_neutral_int=cell2mat(Type_UG_neutral);
Type_UG_phase_int=cell2mat(Type_UG_phase);
Length_UG = cell2mat(UG_line(:,16));
k=1;

for i = 1:length(UG_index)
    
  if (ismember(i,sw_fuse_reg_indices)==0)  
    
    if Length_UG(i)>0
        fprintf(fid,'object underground_line {\n');
        fprintf(fid,'\t name %s;\n',char(UG_line(i,1)));
        fprintf(fid,'\t phases %s;\n',strrep(char(UG_line(i,5)),' ',''));
        fprintf(fid,'\t from %s;\n',char(UG_line(i,3)));
        fprintf(fid,'\t to %s;\n',char(UG_line(i,4)));
        fprintf(fid,'\t length %f;\n',Length_UG(i));
        
        
        conf_UG_type_phases(k,1)=cellstr(UG_line(i,5));conf_UG_neutral(k,1)=Type_UG_neutral_int(i,1);conf_UG_phases(k,1)=Type_UG_phase_int(i,1);
        conf_UG_name(k,1)=strcat(conf_UG_type_phases(k,1),'_',int2str(conf_UG_neutral(k,1)),'_',int2str(conf_UG_phases(k,1)));
        fprintf(fid,'\t configuration underground_line_config_%s;\n',char(conf_UG_name(k,1)));
        k=k+1;
        fprintf(fid,'\t } \n\n');
               
                        %% if length is zero
    else
        fprintf(fid,'object underground_line {\n');
        fprintf(fid,'\t name %s;\n',char(UG_line(i,1)));
        fprintf(fid,'\t phases %s;\n',strrep(char(UG_line(i,5)),' ',''));
        fprintf(fid,'\t from %s;\n',char(UG_line(i,3)));
        fprintf(fid,'\t to %s;\n',char(UG_line(i,4)));
        fprintf(fid,'\t length %f;\n',10);
        
        
        conf_UG_type_phases(k,1)=cellstr(UG_line(i,5));conf_UG_neutral(k,1)=Type_UG_neutral_int(i,1);conf_UG_phases(k,1)=Type_UG_phase_int(i,1);
        conf_UG_name(k,1)=strcat(conf_UG_type_phases(k,1),'_',int2str(conf_UG_neutral(k,1)),'_',int2str(conf_UG_phases(k,1)));
        fprintf(fid,'\t configuration underground_line_config_%s;\n',char(conf_UG_name(k,1)));
        k=k+1;
        fprintf(fid,'\t } \n\n');
               
        
%         nodeIsChild(count,1) = ToNode_UG(i);
%         nodeIsChild(count,2) = FromNode_UG(i);
%         for k = 1:349-deletecount
%             if strcmp(cellstr(ToNode_UG(i)),cellstr(nodes(k)))
%                 nodes(k) = [];
%                 phases(k) = [];
%                 x(k) = [];
%                 y(k) = [];
%                 IsPadMountGear(k) = [];
%                 deletecount = deletecount + 1;
%                 break
%             end
%         end
            
%         count = count + 1;
%         fprintf(fid,'\t bustype PQ;\n');
        %fprintf(fid,'}\n\n\n');
    end
    
  else
     
        for t=1:length (sec_f_reg_sw_info(:,1))       
           if strcmp(cellstr(UG_line(i,1)),cellstr(sec_f_reg_sw_info(t,1)))
           ind=t;        
           end
        end
   
   
        if Length_UG(i)>0
        
        fprintf(fid,'object underground_line {\n');
        fprintf(fid,'\t name %s;\n',char(UG_line(i,1)));
        fprintf(fid,'\t phases %s;\n',strrep(char(UG_line(i,5)),' ',''));
        fprintf(fid,'\t from %s;\n',char(sec_f_reg_sw_info(ind,5)));
        fprintf(fid,'\t to %s;\n',char(UG_line(i,4)));
        fprintf(fid,'\t length %f;\n',Length_UG(i));
        
        conf_UG_type_phases(k,1)=cellstr(UG_line(i,5));conf_UG_neutral(k,1)=Type_UG_neutral_int(i,1);conf_UG_phases(k,1)=Type_UG_phase_int(i,1);
        conf_UG_name(k,1)=strcat(conf_UG_type_phases(k,1),'_',int2str(conf_UG_neutral(k,1)),'_',int2str(conf_UG_phases(k,1)));
        fprintf(fid,'\t configuration underground_line_config_%s;\n',char(conf_UG_name(k,1)));
        k=k+1;
        fprintf(fid,'\t } \n\n');
        
        
        
        %% if length is zero
        else
        fprintf(fid,'object underground_line {\n');
        fprintf(fid,'\t name %s;\n',char(UG_line(i,1)));
        fprintf(fid,'\t phases %s;\n',strrep(char(UG_line(i,5)),' ',''));
        fprintf(fid,'\t from %s;\n',char(sec_f_reg_sw_info(ind,3)));
        fprintf(fid,'\t to %s;\n',char(UG_line(i,4)));
        fprintf(fid,'\t length %f;\n',10);
        
        conf_UG_type_phases(k,1)=cellstr(UG_line(i,5));conf_UG_neutral(k,1)=Type_UG_neutral_int(i,1);conf_UG_phases(k,1)=Type_UG_phase_int(i,1);
        conf_UG_name(k,1)=strcat(conf_UG_type_phases(k,1),'_',int2str(conf_UG_neutral(k,1)),'_',int2str(conf_UG_phases(k,1)));
        fprintf(fid,'\t configuration underground_line_config_%s;\n',char(conf_UG_name(k,1)));
        k=k+1;
        fprintf(fid,'\t } \n\n');   
   
         end
   end
   
    
    
    
    
end

save (strcat(FeederName,'_Feeder_UG_lines'),'conf_UG_name','conf_UG_phases')
%save ('Feeder_UG_lines','conf_UG_name','conf_UG_phases')

end