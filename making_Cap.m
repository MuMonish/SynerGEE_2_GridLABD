
function Make_Capacitor=making_Cap(dir_name,FeederName,NonimalVolt,glm_dir_name)

[CapMatrix,CapText]=xlsread(strcat(dir_name,'\',FeederName,'_Capacitor.xlsx'));%3HT12F1_Capacitor  ROS12F2_Capacitor
[SectionMatrix,SectionText]=xlsread(strcat(dir_name,'\',FeederName,'_Section.xlsx'));%3HT12F1_Section  ROS12F2_Section


GlmFileName=strcat(glm_dir_name,'\','Capacitors_',FeederName,'.glm')
fid = fopen(GlmFileName,'wt');%Capacitors_3HT12F1    Capacitors_ROS12F2
fprintf(fid,strcat('//**Capacitors_',FeederName,':%s\n\n\n'),'');
CapIsOn=CapMatrix(:,1);    % Capacitors status
CapKvar=CapMatrix(:,3:5);

CapSectionID=CapText(2:end,1);% Use to find From and To Node
[SectionsN,Columns]=size(SectionMatrix);
[CapN,Columns2]=size(CapMatrix);
SectionPhaseIndex=5;         %5th Column for Phase
UniqID=CapText(2:end,2);
% Get Capacitor SectionID-FromNode-ToNode-Phase

SectionID=SectionText(2:end,1);
FromNodeId=SectionText(2:end,3);
ToNodeId=SectionText(2:end,4);
SectionPhase=SectionText(2:end,SectionPhaseIndex);
CapSect_Node=cell(CapN,4);
CapSect_Node(:,1)=CapSectionID;

for m=1:CapN
    for n=1:SectionsN
        if strcmp(CapSectionID(m),SectionID(n))
            CapSect_Node(m,2)=FromNodeId(n);
            CapSect_Node(m,3)=ToNodeId(n);
            CapSect_Node(m,4)=SectionPhase(n);
            break;
        end
    end
    
end

for i=1:CapN
    
    fprintf(fid,'object capacitor {\n');
    fprintf(fid,'\t parent %s;\n',char(CapSect_Node(i,3))); %Capacitor is connected to ToNode
    fprintf(fid,'\t name Cap_%s;\n',char(UniqID(i)));
    
    
    if strcmp(CapSect_Node(i,4),'ABCN')
        fprintf(fid,'\t phases ABCN;\n');
        fprintf(fid,'\t phases_connected ABCN;\n');
        fprintf(fid,'\t control MANUAL;\n');
        fprintf(fid, '\tvoltage_set_high  8366;\n');    %7967.43*1.05  Make more general
        fprintf(fid,'\tvoltage_set_low   7569;\n');   %7967.43*0.95
        fprintf(fid,'\t capacitor_A %3f MVAr;\n',CapKvar(i,1)/1000);
        fprintf(fid,'\t capacitor_B %3f MVAr;\n',CapKvar(i,2)/1000);
        fprintf(fid,'\t capacitor_C %3f MVAr;\n',CapKvar(i,3)/1000);
        % 	c;
        % 	capacitor_B 0.5 MVAr;
        % 	capacitor_C 0.5 MVAr;
        
        if CapIsOn(i) == 0
            fprintf(fid,'\t switchA OPEN;\n');
            fprintf(fid,'\t switchB OPEN;\n');
            fprintf(fid,'\t switchC OPEN;\n');
            
        else
            fprintf(fid,'\t switchA CLOSED;\n');
            fprintf(fid,'\t switchB CLOSED;\n');
            fprintf(fid,'\t switchC CLOSED;\n');
            
            
        end
        fprintf(fid,'\t control_level INDIVIDUAL;\n');
        fprintf (fid,'\t nominal_voltage %.2f;\n',NonimalVolt);
        fprintf(fid,'}\n\n\n');
    end
end
fprintf(fid,strcat('//**End Capacitors_',FeederName,'** %s \n\n\n'));

% save Capacitor;

end