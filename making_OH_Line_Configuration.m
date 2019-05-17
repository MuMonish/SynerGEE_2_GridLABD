%% Configuration with impedance model

function making_OH_Line_Configuration(dir_name,FeederName,glm_dir_name,conf_OH_name,conf_OH_phases)

%load(strcat(FeederName,'_Feeder_OH_lines.mat'));
[Conductor_Data,Conductor_type]=xlsread(strcat(dir_name,'\','conductor_warehouse.xlsx'));

Conductor_type(2:end,1)=num2cell(Conductor_Data(:,1));
Conductor_type(2:end,4:13)=num2cell(Conductor_Data(:,4:13));

GlmFileName=strcat(glm_dir_name,'\','OH_Line_Configuration_',FeederName,'.glm')
fid = fopen(GlmFileName,'wt');
fprintf(fid,strcat('//**Overhead  Line configuration for ',FeederName,':%s\n\n\n'),'');

[~, row_index, ~]= unique(conf_OH_name);



for m=1:length(row_index)
    
    fprintf(fid,'object line_configuration {\n');
    fprintf(fid,'\t name overhead_line_config_%s;\n',char(conf_OH_name(row_index(m))));
    
    Rpos=Conductor_type(conf_OH_phases(row_index(m))+1,5);
    Xpos=Conductor_type(conf_OH_phases(row_index(m))+1,6);
    Rzero=Conductor_type(conf_OH_phases(row_index(m))+1,8);
    Xzero=Conductor_type(conf_OH_phases(row_index(m))+1,9);
    Zpos=cell2mat(Rpos)+cell2mat(Xpos)*sqrt(-1);
    Zzero=cell2mat(Rzero)+sqrt(-1)*cell2mat(Xzero);
    Zm=(Zzero-Zpos)/3;
    Zs=(Zzero+2*Zpos)/3;
    
    if imag(Zm)>0
        fprintf(fid,'\t z11 %f+%fj;\n', [real(Zs) imag(Zs)].');
        fprintf(fid,'\t z12 %f+%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z13 %f+%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z21 %f+%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z22 %f+%fj;\n', [real(Zs) imag(Zs)].');
        fprintf(fid,'\t z23 %f+%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z31 %f+%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z32 %f+%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z33 %f+%fj;\n', [real(Zs) imag(Zs)].');
    else % If the imaginary par is negative don't use a +
        fprintf(fid,'\t z11 %f+%fj;\n', [real(Zs) imag(Zs)].');
        fprintf(fid,'\t z12 %f%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z13 %f%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z21 %f%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z22 %f+%fj;\n', [real(Zs) imag(Zs)].');
        fprintf(fid,'\t z23 %f%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z31 %f%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z32 %f%fj;\n', [real(Zm) imag(Zm)].');
        fprintf(fid,'\t z33 %f+%fj;\n', [real(Zs) imag(Zs)].');
        
    end
    fprintf(fid,'\t }\n\n');
end
end