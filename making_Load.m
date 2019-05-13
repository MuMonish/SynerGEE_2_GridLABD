
function Make_Load=making_Load(dir_name,FeederName,NonimalVolt,glm_dir_name)

[LoadMatrix,LoadText]=xlsread(strcat(dir_name,'\',FeederName,'_Load.xlsx'));
[SectionMatrix,SectionText]=xlsread(strcat(dir_name,'\',FeederName,'_Section.xlsx'));
workspace = strcat(FeederName,'_Node_voltages.mat');
load(workspace);
GlmFileName=strcat(glm_dir_name,'\','Loads_',FeederName,'.glm')
fid = fopen(GlmFileName,'wt');
fprintf(fid,strcat('//**Loads_',FeederName,':%s\n\n\n'),'');
[LoadsN,Columns]=size(LoadMatrix);
[SectionsN,Columns2]=size(SectionMatrix);
LoadPhaseIndex=5:10;%Setting
Sabc=zeros(LoadsN,3);

%LoadPhase in  Section Table %Setting
LoadPhaseText=SectionText(2:end,5);
SectionID=SectionText(2:end,1);
FromNodeId=SectionText(2:end,3);
ToNodeId=SectionText(2:end,4);

%SectionID in Load table %Setting
LDSectionID=LoadText(2:end,1);
LDSect_Node=cell(LoadsN,4);
LDSect_Node(:,1)=LDSectionID;
  
  
  
%Power Faction ZIP in Section %Setting
LD_ZIP=zeros(LoadsN,3);
ZIcent=SectionMatrix(:,4:5)/100;%4:5 for distributed load
Pcent=ones(SectionsN,1)-sum(ZIcent,2);
ZIPcent=[ZIcent,Pcent];

  
  % Get Load SectionID-FromNode-ToNode-Phase
for m=1:LoadsN
for n=1:SectionsN
    if strcmp(LDSectionID(m),SectionID(n))
      LDSect_Node(m,2)=FromNodeId(n);
      LDSect_Node(m,3)=ToNodeId(n);
      LDSect_Node(m,4)=LoadPhaseText(n);
      LD_ZIP(m,:)=ZIPcent(n,:);
        break;
    end
end

end



%Base Power(kVA)
n=1;
for m=5:5+2
    Sphase=sqrt(LoadMatrix(:,m).^2+LoadMatrix(:,m+3).^2);%Setting
    direction = sign(cos(angle(LoadMatrix(:,m)-1j*LoadMatrix(:,m+3))));
    Sabc(:,n)=Sphase.*direction; %ABC phase for each column
    
    n=n+1;
end
SabcVA= Sabc*1000;

%Power Factor 
PF=zeros(LoadsN,3);
PLoadmatrix=LoadMatrix(:,5:7);%Setting
for m=1:3
for n=1:LoadsN

    if Sabc(n,m)~=0
    PF(n,m)=PLoadmatrix(n,m)/Sabc(n,m);
    end
end
end



%  double base_power_A[VA]; // in similar format as ZIPload, this represents the nominal power on phase A before applying ZIP fractions
%         double base_power_B[VA]; // in similar format as ZIPload, this represents the nominal power on phase B before applying ZIP fractions
%         double base_power_C[VA]; // in similar format as ZIPload, this represents the nominal power on phase C before applying ZIP fractions
%         double power_pf_A[pu]; // in similar format as ZIPload, this is the power factor of the phase A constant power portion of load
%         double current_pf_A[pu]; // in similar format as ZIPload, this is the power factor of the phase A constant current portion of load
%         double impedance_pf_A[pu]; // in similar format as ZIPload, this is the power factor of the phase A constant impedance portion of load
%         double power_pf_B[pu]; // in similar format as ZIPload, this is the power factor of the phase B constant power portion of load
%         double current_pf_B[pu]; // in similar format as ZIPload, this is the power factor of the phase B constant current portion of load
%         double impedance_pf_B[pu]; // in similar format as ZIPload, this is the power factor of the phase B constant impedance portion of load
%         double power_pf_C[pu]; // in similar format as ZIPload, this is the power factor of the phase C constant power portion of load
%         double current_pf_C[pu]; // in similar format as ZIPload, this is the power factor of the phase C constant current portion of load
%         double impedance_pf_C[pu]; // in similar format as ZIPload, this is the power factor of the phase C constant impedance portion of load
%         double power_fraction_A[pu]; // this is the constant power fraction of base power on phase A
%         double current_fraction_A[pu]; // this is the constant current fraction of base power on phase A
%         double impedance_fraction_A[pu]; // this is the constant impedance fraction of base power on phase A
%         double power_fraction_B[pu]; // this is the constant power fraction of base power on phase B
%         double current_fraction_B[pu]; // this is the constant current fraction of base power on phase B
%         double impedance_fraction_B[pu]; // this is the constant impedance fraction of base power on phase B
%         double power_fraction_C[pu]; // this is the constant power fraction of base power on phase C
%         double current_fraction_C[pu]; // this is the constant current fraction of base power on phase C
%         double impedance_fraction_C[pu]; // this is the constant impedance fraction of base power on phase C

%Distributed load equivalent
for i = 1:LoadsN
    
    fprintf (fid,'object load {\n');
    fprintf (fid,'\t parent %s;\n',char(LDSect_Node(i,3)));%From Node(2) Connected Load ToNode(3)
    fprintf (fid,'\t name LOAD_%s;\n',char(LDSect_Node(i,1)));%Section
    fprintf (fid,'\t phases %s;\n',strrep(char(LDSect_Node(i,4)),' ',''));
    
    fprintf (fid,'\t base_power_A %f;\n',SabcVA(i,1));
    fprintf (fid,'\t base_power_B %f;\n',SabcVA(i,2));
    fprintf (fid,'\t base_power_C %f;\n',SabcVA(i,3));
    
    fprintf (fid,'\t power_pf_A %f;\n',PF(i,1));
    fprintf (fid,'\t current_pf_A %f;\n',PF(i,1));
    fprintf (fid,'\t impedance_pf_A %f;\n',PF(i,1));
    
    fprintf (fid,'\t power_pf_B %f;\n',PF(i,2));
    fprintf (fid,'\t current_pf_B %f;\n',PF(i,2));
    fprintf (fid,'\t impedance_pf_B %f;\n',PF(i,2));
    
    fprintf (fid,'\t power_pf_C %f;\n',PF(i,3));
    fprintf (fid,'\t current_pf_C %f;\n',PF(i,3));
    fprintf (fid,'\t impedance_pf_C %f;\n',PF(i,3));
    
    fprintf (fid,'\t power_fraction_A %.2f;\n',LD_ZIP(i,3));
    fprintf (fid,'\t current_fraction_A %.2f;\n',LD_ZIP(i,2));
    fprintf (fid,'\t impedance_fraction_A %.2f;\n',LD_ZIP(i,1));
    
    fprintf (fid,'\t power_fraction_B %.2f;\n',LD_ZIP(i,3));
    fprintf (fid,'\t current_fraction_B %.2f;\n',LD_ZIP(i,2));
    fprintf (fid,'\t impedance_fraction_B %.2f;\n',LD_ZIP(i,1));
    
    fprintf (fid,'\t power_fraction_C %.2f;\n',LD_ZIP(i,3));
    fprintf (fid,'\t current_fraction_C %.2f;\n',LD_ZIP(i,2));
    fprintf (fid,'\t impedance_fraction_C %.2f;\n',LD_ZIP(i,1));
    
    if (length(low_voltage_nodes)>0)
        element_index= find(strcmp(low_voltage_nodes(:,1),LDSect_Node(i,3)));
    else
        element_index=[];
    end
    if (length(element_index)==1) 
        voltage  = low_voltage_nodes_volt(element_index,1);
        fprintf (fid,'\t nominal_voltage %.2f;\n',voltage);% change voltage  
    else
    fprintf (fid,'\t nominal_voltage %.2f;\n',NonimalVolt);
    end 
    fprintf(fid,'}\n\n\n');
    
end
fprintf(fid,strcat('//**End Loads_',FeederName,'** %s \n\n\n'));

save Load;

save ('Load_ratio.mat','LDSect_Node','LoadMatrix','LD_ZIP')

end