
function Make_Header_File=making_header(FeederName,glm_dir_name,contains_UG)

GlmFileName=strcat(glm_dir_name,'\','Feeder_',FeederName,'.glm')
fid = fopen(GlmFileName,'wt');%Capacitors_3HT12F1    Capacitors_ROS12F2
fprintf(fid,strcat('//**This is a GridLAB-D Model (glm) file for feeder : ',FeederName,'%s\n\n\n'),'');
   
fprintf(fid,'#set profiler=1;\n');
fprintf(fid,'#set iteration_limit=50;\n');
fprintf(fid,'#set minimum_timestep=60;\n');
fprintf(fid,'#set relax_naming_rules=1;\n\n\n');

DT = datetime(now,'ConvertFrom','datenum');
DT.Format = 'yyyy-MM-dd HH:mm:ss';

fprintf(fid,'clock {\n');
fprintf(fid,'\t timezone PST+8PDT;\n');
fprintf(fid,'\t starttime ''%s'';\n',char(DT));
fprintf(fid,'\t stoptime ''%s'';\n',char(DT));
fprintf(fid,'}\n\n\n');

fprintf(fid,'module powerflow{\n');
fprintf(fid,'\t solver_method NR;\n');
fprintf(fid,'\t default_maximum_voltage_error 1e-6;\n');
fprintf(fid,'\t NR_superLU_procs 1;\n');
fprintf(fid,'\t line_capacitance true;\n');
fprintf(fid,'}\n\n\n');

fprintf(fid,'module residential;\n');
fprintf(fid,'module generators;\n');
fprintf(fid,'module tape;\n');

fprintf(fid,'//Substation interconnects \n');
glm_files=dir([glm_dir_name '/*.glm']);

for i=1:length(glm_files)
    if (strcmp(glm_files(i,:).name,strcat('Feeder_',FeederName,'.glm')))==0
        fprintf(fid,'#include "%s";\n',glm_files(i,:).name);
    end
end
fprintf(fid,'\n\n');
fprintf(fid,'object collector {\n');
fprintf(fid,'\t name loss_OH;\n');
fprintf(fid,'\t group class=overhead_line;\n');
fprintf(fid,'\t property sum(power_losses.real);\n');
fprintf(fid,'\t file "OH_lines_losses.csv";\n');
fprintf(fid,'}\n\n\n');

if contains_UG
    fprintf(fid,'object collector {\n');
    fprintf(fid,'\t name loss_UG;\n');
    fprintf(fid,'\t group class=underground_line;\n');
    fprintf(fid,'\t property sum(power_losses.real);\n');
    fprintf(fid,'\t file "UG_lines_losses.csv";\n');
    fprintf(fid,'}\n\n\n');
end

fprintf(fid,'object voltdump {\n');
fprintf(fid,'\t filename output_voltage.csv;\n');
fprintf(fid,'\t mode polar;\n');
fprintf(fid,'}\n\n\n');

fprintf(fid,'object currdump {\n');
fprintf(fid,'\t filename output_current.csv;\n');
fprintf(fid,'\t mode polar;\n');
fprintf(fid,'}\n\n\n');

fclose('all')
end