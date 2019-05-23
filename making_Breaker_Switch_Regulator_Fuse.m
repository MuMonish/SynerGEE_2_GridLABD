%%Combine Switch, Regulator and Fuse
%*******Assume all switches and fuses are in "closed and good status"******
% Assume all closed?
% Gridlab-D will produce errors if the feeder has sections islanded by open switches.
function SecFromTo=making_Breaker_Switch_Regulator_Fuse(feeder_Section,feeder_Switches,feeder_Regulators,Regulators_config,feeder_Fuses,feeder_Breakers,feeder_Xfmrs,Transformers_config,FeederName,NonimalVolt,glm_dir_name,AllClosed)
SectionID=feeder_Section(:,1);
FromNodeId=feeder_Section(:,3);
ToNodeId=feeder_Section(:,4);
SectionPhase=feeder_Section(:,5);

[SectionsN,~]=size(feeder_Section);
%% Switch   Starts
disp('Switch Starts')
[SwitchN,~]=size(feeder_Switches);
if SwitchN > 0
    SwitchOpen=cell2mat(feeder_Switches(:,5));    % Switch status
    SwitchSectionID=feeder_Switches(:,1);% Use to find From and To Node
    SW_UniqID=feeder_Switches(:,2);
    % Get Switch SectionID-FromNode-ToNode-Phase
    
    SwitchSect_Node=cell(SwitchN,5);% create new node for switch
    SwitchSect_Node(:,1)=SwitchSectionID;
    
    
    for m=1:SwitchN
        for n=1:SectionsN
            if strcmp(SwitchSectionID(m),SectionID(n))
                SwitchSect_Node(m,2)=FromNodeId(n);
                SwitchSect_Node(m,3)=ToNodeId(n);
                SwitchSect_Node(m,4)=SectionPhase(n);
                %create new nodes for swiches
                SwitchSect_Node(m,5)={strcat('SW_',char(FromNodeId(n)))};% BASED ON FROM NODE
                break;
            end
        end
        
    end
end
%% Regulator starts
disp('Regulator Starts')
[RegulatorN,~]=size(feeder_Regulators);
[RegConfigN,~]=size(Regulators_config);
if RegConfigN > 0
    RegSectionID=feeder_Regulators(:,1);% Use to find From and To Node
    RegType=feeder_Regulators(:,4);
    RegConnect=feeder_Regulators(:,14);
    RegCofigType=Regulators_config(:,1);
    Reg_UniqID=feeder_Regulators(:,2);
    
    reg_ct_ratio = cell2mat(Regulators_config(:,10));
    reg_pt_ratio = cell2mat(Regulators_config(:,9));
    reg_RX_settings = cell2mat(feeder_Regulators(:,21:26));
    reg_tap_positions = cell2mat(feeder_Regulators(:,15:17));
    reg_BandCenter = cell2mat(feeder_Regulators(:,18));
    reg_BandWidth = cell2mat(feeder_Regulators(:,27));
    % Get SWitch SectionID-FromNode-ToNode-Phase
    
    RegulatorSect_Node=cell(RegulatorN,7);%section, from node, to node, phase, config_N, cofig_name, New created node
    RegulatorSect_Node(:,1)=RegSectionID;
    
    for m=1:RegulatorN
        for n=1:SectionsN
            if strcmp(RegSectionID(m),SectionID(n))
                RegulatorSect_Node(m,2)=FromNodeId(n);
                RegulatorSect_Node(m,3)=ToNodeId(n);
                RegulatorSect_Node(m,4)=SectionPhase(n);
                %create new nodes for regulators
                RegulatorSect_Node(m,7)={strcat('Reg_',char(FromNodeId(n)))};
                break;
            else
                if n==SectionsN
                    fprintf('Can not find Section %s',char(RegSectionID(m)));
                end
            end
            
        end
        
    end
    
    Reg_NewNode=[RegulatorSect_Node(:,1:4),RegulatorSect_Node(:,7)];
end

%% Fuse Starts
disp('Fuse Starts')
[FuseN,~]=size(feeder_Fuses);
if FuseN > 0
    FuseIsOpen=cell2mat(feeder_Fuses(:,17)); % Fuse status
    FuseCutoffAmp=cell2mat(feeder_Fuses(:,10));
    RepairHours=cell2mat(feeder_Fuses(:,22));
    mean_replacement_time = RepairHours*3600;
    
    FuseSectionID=feeder_Fuses(:,1);% Use to find From and To Node
    Fuse_UniqID=feeder_Fuses(:,2);
    % Get Fuses SectionID-FromNode-ToNode-Phase
    
    FuseSect_Node=cell(FuseN,6);        %Create new nodes for serial fuses
    FuseSect_Node(:,1)=FuseSectionID;
    FuseSect_Node(:,5)=feeder_Fuses(:,11);
    
    for m=1:FuseN
        for n=1:SectionsN
            if strcmp(FuseSectionID(m),SectionID(n))
                FuseSect_Node(m,2)=FromNodeId(n);
                FuseSect_Node(m,3)=ToNodeId(n);
                FuseSect_Node(m,4)=SectionPhase(n);
                %Create new nodes for serial fuses
                FuseSect_Node(m,6)={strcat('Fuse_',char(ToNodeId(n)))};% change to ToNode to avoid duplicate
                
                break;
            end
        end
        
    end
    
    Fuse_NewNode=[FuseSect_Node(:,1:4),FuseSect_Node(:,6)];
end
%% Breakers Starts
disp('Breakers Starts')
% [BreakerMatrix,BreakerText]=xlsread(strcat(dir_name,'\',FeederName,'_Breakers.xlsx'));%xlsread('3HT12F1_Switches.xlsx');
[BreakerN,~]=size(feeder_Breakers);
if BreakerN > 0
    BreakerOpen=cell2mat(feeder_Breakers(:,47)); % Column 47 is 1 if open
    BreakerSect_Node=cell(BreakerN,6);        %Create new nodes for serial breakers
    BreakerSect_Node(:,5)=feeder_Breakers(:,44);
    Breaker_UniqID=feeder_Breakers(:,2);
    BreakerSectionID=feeder_Breakers(:,1);
    BreakerSect_Node(:,1)=BreakerSectionID;
    % Make sure each Breaker_uniqID is unique
    if length(Breaker_UniqID) > length(unique(Breaker_UniqID))
        for i = 1:length(Breaker_UniqID)
            sameIDs = Breaker_UniqID(ismember(Breaker_UniqID,Breaker_UniqID(i)));
            sameID_index = find(ismember(Breaker_UniqID,Breaker_UniqID(i)));
            if length(sameIDs) > 1
                for j = 1:length(sameIDs)
                    Breaker_UniqID(sameID_index(j)) = {char(strcat(Breaker_UniqID(sameID_index(j)),"_",FeederName,"_",num2str(j)))};
                end
            end
        end
    end
    
    for m=1:BreakerN
        for n=1:SectionsN
            if strcmp(feeder_Breakers(m,1),SectionID(n))
                BreakerSect_Node(m,1)=feeder_Breakers(m,1);
                BreakerSect_Node(m,2)=FromNodeId(n);
                BreakerSect_Node(m,3)=ToNodeId(n);
                BreakerSect_Node(m,4)=SectionPhase(n);
                %Create new nodes for serial fuses
                BreakerSect_Node(m,6)={strcat('Breaker_',char(ToNodeId(n)))};% change to ToNode to avoid duplicate
                
                break;
            end
        end
        
    end
    
    Breaker_NewNode=[BreakerSect_Node(:,1:4),BreakerSect_Node(:,6)];
end

%% Transformers Starts
disp('Transformers Starts')
XfmrConfigMatrix = cell2mat(Transformers_config(:,2:10));
[XfmrN,~]=size(feeder_Xfmrs);
[XfmrConfigN,~]=size(Transformers_config);
if XfmrN > 0
    XfmrType=feeder_Xfmrs(:,4);
    XfmrConnect_high=feeder_Xfmrs(:,12);
    XfmrConnect_low=feeder_Xfmrs(:,13);
    XfmrCofigType=Transformers_config(:,1);
    Xfmr_UniqID=feeder_Xfmrs(:,2);
    XfmrSectionID=feeder_Xfmrs(:,1);% Use to find From and To Node
    % Get SWitch SectionID-FromNode-ToNode-Phase
    
    XfmrSect_Node=cell(XfmrN,7);%section, from node, to node, phase, config_N, cofig_name, New created node
    XfmrSect_Node(:,1)=XfmrSectionID;
    
    for m=1:XfmrN
        for n=1:SectionsN
            if strcmp(XfmrSectionID(m),SectionID(n))
                XfmrSect_Node(m,2)=FromNodeId(n);
                XfmrSect_Node(m,3)=ToNodeId(n);
                XfmrSect_Node(m,4)=SectionPhase(n);
                %create new nodes for regulators
                XfmrSect_Node(m,7)={strcat('Xfmr_',char(ToNodeId(n)))};
                break;
            else
                if n==SectionsN
                    fprintf('Can not find Section %s',char(RegSectionID(m)));
                end
            end
            
        end
    end
    Xfmr_NewNode=[XfmrSect_Node(:,1:4),XfmrSect_Node(:,7)];
end

%% Count duplicate Section ID-------Two or Three components may be in the same section
disp('Count duplicate Section ID')
% SectionAll =[;BreakerSect_Node(:,1);SwitchSect_Node(:,1);RegulatorSect_Node(:,1);FuseSect_Node(:,1); XfmrSect_Node] ;
SectionAll = [];
if BreakerN > 0
    SectionAll = [SectionAll; BreakerSect_Node(:,1)];
end
if SwitchN > 0
    SectionAll = [SectionAll; SwitchSect_Node(:,1)];
end
if RegulatorN > 0
    SectionAll = [SectionAll; RegulatorSect_Node(:,1)];
end
if FuseN > 0
    SectionAll = [SectionAll; FuseSect_Node(:,1)];
end
if XfmrN > 0
    SectionAll = [SectionAll; XfmrSect_Node(:,1)];
end

[UniqSection,~,UniqIdex ] = unique(SectionAll);
[gatherIndex, bin]=histc(UniqIdex,unique(UniqIdex));

multiple = find(gatherIndex > 1);

% Create duplicate matrix   SectionId---Duplicate Times---ThoseIndex
DupSectN=length(multiple);
DuplicateMatrix=cell(DupSectN,3);

for m=1:DupSectN
    DuplicateMatrix(m,1)=UniqSection(multiple(m));
    DuplicateMatrix(m,2)=num2cell(gatherIndex(multiple(m)));
    
    DuplicateMatrix(m,3) = num2cell(find(ismember(bin, multiple(m))),1);% Section Duplicated Index
end

%Print out douplicate SECTION id
SectionDupIndex=find(ismember(bin, multiple(m)));

for m=1:length(SectionDupIndex)
    fprintf('%s\n',char(SectionAll(SectionDupIndex(m))));
end

%% SecFromTo=[Breaker_NewNode;SwitchSect_Node;Reg_NewNode;Fuse_NewNode:Xfmr_NewNode];
disp('SecFromTo')
SecFromTo = [];
if BreakerN > 0
    SecFromTo = [SecFromTo; Breaker_NewNode];
end
if SwitchN > 0
    SecFromTo = [SecFromTo; SwitchSect_Node];
end
if RegulatorN > 0
    SecFromTo = [SecFromTo; Reg_NewNode];
end
if FuseN > 0
    SecFromTo = [SecFromTo; Fuse_NewNode];
end
if XfmrN > 0
    SecFromTo = [SecFromTo; Xfmr_NewNode];
end

for m=1:DupSectN
    if cell2mat(DuplicateMatrix(m,2))==2
        DupIndex=cell2mat(DuplicateMatrix(m,3));
        SecFromTo(DupIndex(2),2)=SecFromTo(DupIndex(1),5);
    else
        fprintf('There are 3 componets in same section')
    end
    % Section Duplicated Index
end
%% adding Nomial Voltage as another element in the matrix
SecFromTo(:,size(SecFromTo,2)+1) = num2cell(NonimalVolt*ones(size(SecFromTo,1),1));
%%
%PRINT OUT

%% Print Breaker
disp('Print Breaker')
if BreakerN > 0
    BreakerSect_Node=SecFromTo(1:BreakerN,:);
    if AllClosed
        GlmFileName=strcat(glm_dir_name,'\','Breakers_',FeederName,'_Closed.glm');
    else
        GlmFileName=strcat(glm_dir_name,'\','Breakers_',FeederName,'_O-C.glm'); % '_O-C' tells making_header not to include it
    end
    
    fid = fopen(GlmFileName,'wt');
    fprintf(fid,strcat('//**Breakers_',FeederName,':%s\n\n\n'),'');
    
    for i=1:BreakerN
        
        fprintf(fid,'object recloser {\n');
        fprintf(fid,'\tname recloser_%s;\n',char(Breaker_UniqID(i)));
        fprintf(fid,'\tphases "%s";\n',strrep(char(BreakerSect_Node(i,4)),' ',''));
        fprintf(fid,'\tfrom %s;\n',char(BreakerSect_Node(i,2)));
        fprintf(fid,'\tto %s;\n', char(BreakerSect_Node(i,5)));
        fprintf(fid,'\tretry_time 1s;\n');
        fprintf(fid,'\tmax_number_of_tries 3;\n');
        if (BreakerOpen(i) == 1) && (~AllClosed)
            fprintf(fid,'\tstatus OPEN;\n');
        end
        fprintf(fid,'}\n\n\n');
        
    end
end

%% Print Switch
disp('Print Switch')
if SwitchN > 0
    SwitchSect_Node(:,2)=SecFromTo(BreakerN+1:BreakerN+SwitchN,2);
    if AllClosed
        GlmFileName=strcat(glm_dir_name,'\','Switches_',FeederName,'_Closed.glm');
    else
        GlmFileName=strcat(glm_dir_name,'\','Switches_',FeederName,'_O-C.glm'); %'_O-C' tells making_header not to include it
    end
    fid = fopen(GlmFileName,'wt');
    fprintf(fid,strcat('//**Switches_',FeederName,':%s\n\n\n'),'');
    
    for i=1:SwitchN
        %Switch
        fprintf(fid,'object switch {\n');
        fprintf(fid,'\tname Switch_%s;\n',char(SW_UniqID(i)));
        fprintf(fid,'\tphases %s;\n',strrep(char(SwitchSect_Node(i,4)),' ',''));
        fprintf(fid,'\tfrom %s;\n',char(SwitchSect_Node(i,2)));
        fprintf(fid,'\tto %s;\n',char(SwitchSect_Node(i,5)));%% TO NEW CREATED NODE
        if (SwitchOpen(i) == 1) && (~AllClosed)
            state = 'Open';
        else
            state = 'CLOSED';
        end
        
        if ismember('A',char(SwitchSect_Node(i,4)))
            fprintf(fid,'\tphase_A_state %s;\n',state);
        end
        if ismember('B',char(SwitchSect_Node(i,4)))
            fprintf(fid,'\tphase_B_state %s;\n',state);
        end
        if ismember('C',char(SwitchSect_Node(i,4)))
            fprintf(fid,'\tphase_C_state %s;\n',state);
        end
        fprintf(fid,'\toperating_mode INDIVIDUAL;\n');
        fprintf(fid,'}\n');
    end
    
    fprintf(fid,strcat('//**End Switches_',FeederName,'** %s \n\n\n'));
    
    % save Switches_Closed;
end
%% Print out Regulator
disp('Print Regulator')
if RegulatorN > 0
    
    GlmFileName_reg=strcat(glm_dir_name,'\','Regulators_',FeederName,'_Closed.glm');
    
    fid = fopen(GlmFileName_reg,'wt');
    fprintf(fid,strcat('//**Regulators_',FeederName,':%s\n\n\n'),'');
    
    % Regulator Configuration
    
    for m=1:RegulatorN
        for n=1:RegConfigN
            if strcmp(RegType(m),RegCofigType(n))
                conf_Reg_name=strcat(num2str(n),'_',FeederName);
                fprintf(fid,'object regulator_configuration {\n');
                fprintf(fid,'\tname Reg_Config_%s;\n',conf_Reg_name);
                RegulatorSect_Node(m,5)=cellstr(conf_Reg_name);
                RegulatorSect_Node(m,6)=RegCofigType(n);
                
                if strcmp(RegConnect(m),'YG')
                    fprintf(fid,'\tconnect_type 1;\n');
                    
                end
                
                fprintf(fid,'\tband_center %d;\n',reg_BandCenter(m));
                fprintf(fid,'\tband_width %d;\n',reg_BandWidth(m));
                fprintf(fid,'\ttime_delay 30.0;\n');
                fprintf(fid,'\traise_taps 16;\n');
                fprintf(fid,'\tlower_taps 16;\n');
                fprintf(fid,'\tcurrent_transducer_ratio %d;\n',reg_ct_ratio(n));
                fprintf(fid,'\tpower_transducer_ratio %d;\n',reg_pt_ratio(n));
                
                fprintf(fid,'\tcompensator_r_setting_A %d;\n',reg_RX_settings(m,1));
                fprintf(fid,'\tcompensator_r_setting_B %d;\n',reg_RX_settings(m,2));
                fprintf(fid,'\tcompensator_r_setting_C %d;\n',reg_RX_settings(m,3));
                fprintf(fid,'\tcompensator_x_setting_A %d;\n',reg_RX_settings(m,4));
                fprintf(fid,'\tcompensator_x_setting_B %d;\n',reg_RX_settings(m,5));
                fprintf(fid,'\tcompensator_x_setting_C %d;\n',reg_RX_settings(m,6));
                
                fprintf(fid,'\tCT_phase "%s";\n',char(feeder_Regulators(m,3)));
                fprintf(fid,'\tPT_phase "%s";\n',char(feeder_Regulators(m,3)));
                
                fprintf(fid,'\tregulation 0.10;\n');
                fprintf(fid,'\tControl LINE_DROP_COMP;\n');
                fprintf(fid,'\tcontrol_level INDIVIDUAL;\n');
                fprintf(fid,'\tType B;\n');
                
                fprintf(fid,'\ttap_pos_A %d;\n',reg_tap_positions(m,1) );
                fprintf(fid,'\ttap_pos_B %d;\n',reg_tap_positions(m,2) );
                fprintf(fid,'\ttap_pos_C %d;\n',reg_tap_positions(m,3) );
                
                fprintf(fid,'}\n\n\n\n');
                
            end
        end
    end
    
    % Object Regulator Change to NEW From Node
    RegulatorSect_Node(:,2)=SecFromTo(BreakerN+SwitchN+1:BreakerN+SwitchN+RegulatorN,2);
    
    for i=1:RegulatorN
        %Switch
        fprintf(fid,'object regulator {\n');
        fprintf(fid,'\tname Regulator_%s;\n',char(Reg_UniqID(i)));
        fprintf(fid,'\tphases %s;\n',strrep(char(RegulatorSect_Node(i,4)),' ',''));
        fprintf(fid,'\tfrom %s;\n',char(RegulatorSect_Node(i,2)));
        fprintf(fid,'\tto %s;\n',char(RegulatorSect_Node(i,7)));           %To new created node
        fprintf(fid,'\tconfiguration Reg_Config_%s;\n',char(RegulatorSect_Node(i,5)));
        fprintf(fid,'}\n\n\n');
    end
    
    fprintf(fid,strcat('//**End Regulator_',FeederName,'** %s \n\n\n'));
    
    % save Regulator;
end

%% Print out Transformers
disp('Print Transformers')
if XfmrN > 0
    GlmFileName_Xfmr=strcat(glm_dir_name,'\','Transformers_',FeederName,'_Closed.glm');
    fid = fopen(GlmFileName_Xfmr,'wt');
    fprintf(fid,strcat('//**Transformers_',FeederName,':%s\n\n\n'),'');
    
    % Transformer Configuration
    for m=1:XfmrN
        for n=1:XfmrConfigN
            if strcmp(XfmrType(m),XfmrCofigType(n))
                conf_Xfmr_name=strcat(num2str(n),'_',FeederName);
                XfmrSect_Node(m,5)=cellstr(conf_Xfmr_name);
                XfmrSect_Node(m,6)=XfmrCofigType(n);
                low_voltage(m,1) = XfmrConfigMatrix(n,3)*1000/sqrt(3);
                if m==1
                    uniqueXfmr = 1;
                else
                    uniqueXfmr = ~ismember(str2num(cell2mat(XfmrSect_Node(m,5))),str2num(cell2mat(XfmrSect_Node(1:m-1,5))));
                end
                if uniqueXfmr
                    fprintf(fid,'object transformer_configuration {\n');
                    fprintf(fid,'\tname Xfmr_Config_%s;\n',conf_Xfmr_name);
                    
                    if (strcmp(XfmrConnect_high(m),'YG') == 1) && (strcmp(XfmrConnect_low(m),'YG') == 1)
                        fprintf(fid,'\tconnect_type WYE_WYE;\n');
                    else
                        fprintf(fid,'\tconnect_type DELTA_GWYE;\n');
                    end
                    
                    if XfmrConfigMatrix(n,3)<2
                        fprintf(fid,'\tinstall_type POLETOP;\n');
                    else
                        fprintf(fid,'\tinstall_type PADMOUNT;\n');
                    end
                    
                    fprintf(fid,'\tprimary_voltage %d;\n',XfmrConfigMatrix(n,2)*1000/sqrt(3));
                    fprintf(fid,'\tsecondary_voltage %d;\n',XfmrConfigMatrix(n,3)*1000/sqrt(3));
                    fprintf(fid,'\tpower_rating %d;\n',XfmrConfigMatrix(n,4));
                    %fprintf(fid,'\tresistance %d;\n',XfmrConfigMatrix(n,6)/XfmrConfigMatrix(n,4));
                    fprintf(fid,'\timpedance %d+%dj;\n',XfmrConfigMatrix(n,6)/XfmrConfigMatrix(n,4),XfmrConfigMatrix(n,5)/XfmrConfigMatrix(n,4));
                    fprintf(fid,'\tno_load_loss %d;\n',XfmrConfigMatrix(n,9));
                    
                    fprintf(fid,'}\n\n\n\n');
                end
            end
        end
    end
    
    % Object Regulator Change to NEW From Node
    XfmrSect_Node(:,2)=SecFromTo(BreakerN+SwitchN+RegulatorN+FuseN+1:BreakerN+SwitchN+RegulatorN+FuseN+XfmrN,2);
    
    for i=1:XfmrN
        %Switch
        fprintf(fid,'object transformer  {\n');
        fprintf(fid,'\tname Trafo_%s;\n',char(Xfmr_UniqID(i)));
        fprintf(fid,'\tphases %s;\n',strrep(char(XfmrSect_Node(i,4)),' ',''));
        fprintf(fid,'\tfrom %s;\n',char(XfmrSect_Node(i,2)));
        fprintf(fid,'\tto %s;\n',char(XfmrSect_Node(i,7)));           %To new created node
        fprintf(fid,'\tconfiguration Xfmr_Config_%s;\n',char(XfmrSect_Node(i,5)));
        fprintf(fid,'}\n\n\n');
        index = find(strcmp(SecFromTo(:,5), char(XfmrSect_Node(i,7))));
        SecFromTo(index,6) = num2cell(low_voltage(i,1));
        
    end
    
    fprintf(fid,strcat('//**End Transformers_',FeederName,'** %s \n\n\n'));
    
    % save Transformers;
end
%% Print Fuses
disp('Print Fuses')
if FuseN > 0
    FuseSect_Node(:,2)=SecFromTo(BreakerN+SwitchN+RegulatorN+1:BreakerN+SwitchN+RegulatorN+FuseN,2);
    if AllClosed
        GlmFileName_fuse=strcat(glm_dir_name,'\','Fuses_',FeederName,'_Closed.glm');
    else
        GlmFileName_fuse=strcat(glm_dir_name,'\','Fuses_',FeederName,'_O-C.glm'); % '_O-C' tells making_header not to include it
    end
    
    fid = fopen(GlmFileName_fuse,'wt');
    fprintf(fid,strcat('//**Fuses_',FeederName,':%s\n\n\n'),'');
    
    for i=1:FuseN
        
        fprintf(fid,'object fuse {\n');
        
        fprintf(fid,'\tname FUSEs_%s;\n',char(Fuse_UniqID(i)));
        
        fprintf(fid,'\tphases "%s";\n',strrep(char(FuseSect_Node(i,4)),' ',''));
        
        fprintf(fid,'\tfrom %s;\n',char(FuseSect_Node(i,2)));
        fprintf(fid,'\tto %s;\n', char(FuseSect_Node(i,6)));% connect to new fuse node
        fprintf(fid,'\tcurrent_limit %d A;\n',FuseCutoffAmp(i));
        fprintf(fid,'\tmean_replacement_time %3d ;\n',mean_replacement_time);
        
        
        if (FuseIsOpen(i)==0) || (~AllClosed)
            
            fprintf(fid,'\tphase_A_status GOOD;\n');
            fprintf(fid,'\tphase_B_status GOOD;\n');
            fprintf(fid,'\tphase_C_status GOOD;\n');
        else
            
            fprintf(fid,'\tphase_A_status BLOWN;\n');%Original state is BLOWN if FuseOpen==1
            fprintf(fid,'\tphase_B_status BLOWN;\n');
            fprintf(fid,'\tphase_C_status BLOWN;\n');
        end
        fprintf(fid,'\trepair_dist_type NONE;\n');
        fprintf(fid,'}\n\n\n');
        
    end
    
    fprintf(fid,strcat('//**End Fuses_',FeederName,'** %s \n\n\n'));
    
    % save Fuses_Good;
end

%% Order =  Transfomer -> FuseN -> RegulatorN -> SwitchN -> BreakerN
SecFromto_ordered=[
    SecFromTo(BreakerN+SwitchN+RegulatorN+FuseN+1:BreakerN+SwitchN+RegulatorN+FuseN+XfmrN,:);
    SecFromTo(BreakerN+SwitchN+RegulatorN+1:BreakerN+SwitchN+RegulatorN+FuseN,:);
    SecFromTo(BreakerN+SwitchN+1:BreakerN+SwitchN+RegulatorN,:);
    SecFromTo(BreakerN+1:BreakerN+SwitchN,:);
    SecFromTo(1:BreakerN,:)
    ];

SecFromTo=strrep(SecFromto_ordered(:,1:5),' ','');
SecFromTo(:,6)=SecFromto_ordered(:,6);

%save(strcat(FeederName,'_SectionFromTo'),'SecFromTo')

end
