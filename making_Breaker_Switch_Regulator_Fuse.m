%%Combine Switch, Regulator and Fuse
%*******Assume all switches and fuses are in "closed and good status"******

function Make_Breaker_Switch_Regulator_Fuse=making_Breaker_Switch_Regulator_Fuse(dir_name,FeederName,NonimalVolt,glm_dir_name,AllClosed)
% Assume all closed?
% Gridlab-D will produce errors if the feeder has sections islanded by open switches.
%% Switch   Starts

[SwitchMatrix,SwitchText]=xlsread(strcat(dir_name,'\',FeederName,'_Switches.xlsx'));%xlsread('3HT12F1_Switches.xlsx');
[SectionMatrix,SectionText]=xlsread(strcat(dir_name,'\',FeederName,'_Section.xlsx'));%xlsread('3HT12F1_Section.xlsx');
[SectionsN,Columns]=size(SectionMatrix);
[SwitchN,Columns2]=size(SwitchMatrix);
if size(SwitchMatrix,1) > 0
    SwitchOpen=SwitchMatrix(:,2);    % Switch status
    SwithSectionID=SwitchText(2:end,1);% Use to find From and To Node
    
    SectionPhaseIndex=5;         %5th Column for Phase
    SW_UniqID=SwitchText(2:end,2);
    % Get SWitch SectionID-FromNode-ToNode-Phase
    
    SectionID=SectionText(2:end,1);
    FromNodeId=SectionText(2:end,3);
    ToNodeId=SectionText(2:end,4);
    SectionPhase=SectionText(2:end,SectionPhaseIndex);
    SwitchSect_Node=cell(SwitchN,5);% create new node for switch
    SwitchSect_Node(:,1)=SwithSectionID;
    
    
    for m=1:SwitchN
        for n=1:SectionsN
            if strcmp(SwithSectionID(m),SectionID(n))
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

[RegConfigMatrix,RegConfigText]=xlsread(strcat(dir_name,'\','regulator_warehouse.xlsx'));
[RegulatorMatrix,RegulatorText]=xlsread(strcat(dir_name,'\',FeederName,'_Regulators.xlsx'));
%[SectionMatrix,SectionText]=xlsread('3HT12F1_Section.xlsx');
[RegulatorN,Columns2]=size(RegulatorMatrix);
[RegConfigN,Columns3]=size(RegConfigMatrix);
if size(RegulatorMatrix,1) > 0
    RegSectionID=RegulatorText(2:end,1);% Use to find From and To Node
    %[SectionsN,Columns]=size(SectionMatrix);
    SectionPhaseIndex=5;         %5th Column for Phase
    RegType=RegulatorText(2:end,4);
    RegConnect=RegulatorText(2:end,14);
    RegCofigType=RegConfigText(2:end,1);
    Reg_UniqID=RegulatorText(2:end,2);
    
    
    % Get SWitch SectionID-FromNode-ToNode-Phase
    
    SectionID=SectionText(2:end,1);
    FromNodeId=SectionText(2:end,3);
    ToNodeId=SectionText(2:end,4);
    SectionPhase=SectionText(2:end,SectionPhaseIndex);
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
[FuseMatrix,FuseText]=xlsread(strcat(dir_name,'\',FeederName,'_Fuses.xlsx'));
%[SectionMatrix,SectionText]=xlsread('3HT12F1_Section.xlsx');

[FuseN,Columns2]=size(FuseMatrix);
[SectionsN,Columns]=size(SectionMatrix);
if size(FuseMatrix, 1) > 0
    FuseIsOpen=FuseMatrix(:,15); % Fuse status
    FuseCutoffAmp=FuseMatrix(:,8);
    RepairHours=FuseMatrix(:,2);
    
    FuseSectionID=FuseText(2:end,1);% Use to find From and To Node
    SectionPhaseIndex=5;         %5th Column for Phase
    Fuse_UniqID=FuseText(2:end,2);
    % Get Fuses SectionID-FromNode-ToNode-Phase
    
    SectionID=SectionText(2:end,1);
    FromNodeId=SectionText(2:end,3);
    ToNodeId=SectionText(2:end,4);
    SectionPhase=SectionText(2:end,SectionPhaseIndex);
    FuseSect_Node=cell(FuseN,6);        %Create new nodes for serial fuses
    FuseSect_Node(:,1)=FuseSectionID;
    FuseSect_Node(:,5)=FuseText(2:end,11);
    
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
%% Breakers;
[BreakerMatrix,BreakerText]=xlsread(strcat(dir_name,'\',FeederName,'_Breakers.xlsx'));%xlsread('3HT12F1_Switches.xlsx');
[BreakerN,Columns2]=size(BreakerMatrix);
if size(BreakerMatrix,1) > 0
    BreakerOpen=BreakerMatrix(:,45); % Column 45 is 1 if open
    BreakerSectionID=BreakerText(2:end,1);
    BreakerSect_Node=cell(BreakerN,6);        %Create new nodes for serial breakers
    BreakerSect_Node(:,1)=BreakerSectionID;
    BreakerSect_Node(:,5)=BreakerText(2:end,44);
    Breaker_UniqID=BreakerText(2:end,2);
    
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
            if strcmp(BreakerText(m+1,1),SectionID(n))
                BreakerSect_Node(m,1)=BreakerText(m+1,1);
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

%% Transformers;
[XfmrConfigMatrix,XfmrConfigText]=xlsread(strcat(dir_name,'\','transformer_warehouse.xlsx'));
[XfmrMatrix,XfmrText]=xlsread(strcat(dir_name,'\',FeederName,'_PrimaryTransformers.xlsx'));%xlsread('3HT12F1_Switches.xlsx');

[XfmrN,Columns2]=size(XfmrMatrix);
[XfmrConfigN,Columns3]=size(XfmrConfigMatrix);
if size(XfmrMatrix,1) > 0
    XfmrSectionID=XfmrText(2:end,1);% Use to find From and To Node
    %[SectionsN,Columns]=size(SectionMatrix);
    SectionPhaseIndex=5;         %5th Column for Phase in section data
    XfmrType=XfmrText(2:end,4);
    XfmrConnect_high=XfmrText(2:end,12);
    XfmrConnect_low=XfmrText(2:end,13);
    XfmrCofigType=XfmrConfigText(2:end,1);
    Xfmr_UniqID=XfmrText(2:end,2);
    
    
    % Get SWitch SectionID-FromNode-ToNode-Phase
    
    SectionID=SectionText(2:end,1);
    FromNodeId=SectionText(2:end,3);
    ToNodeId=SectionText(2:end,4);
    SectionPhase=SectionText(2:end,SectionPhaseIndex);
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

[UniqSection,OriginalIndex,UniqIdex ] = unique(SectionAll);
[gatherIndex, bin]=histc(UniqIdex,unique(UniqIdex));

multiple = find(gatherIndex > 1);

%create duplicate matrix   SectionId---Duplicate Times---ThoseIndex
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
if size(BreakerMatrix,1) > 0
    BreakerSect_Node=SecFromTo(1:BreakerN,:);
    if AllClosed
        GlmFileName=strcat(glm_dir_name,'\','Breakers_',FeederName,'_Closed.glm')
    else
        GlmFileName=strcat(glm_dir_name,'\','Breakers_',FeederName,'_O-C.glm') % '_O-C' tells making_header not to include it
    end
    
    fid = fopen(GlmFileName,'wt');
    fprintf(fid,strcat('//**Breakers_',FeederName,':%s\n\n\n'),'');
    
    for i=1:BreakerN
        
        fprintf(fid,'object recloser {\n');
        fprintf(fid,'\t name recloser_%s;\n',char(Breaker_UniqID(i)));
        fprintf(fid,'\t phases "%s";\n',strrep(char(BreakerSect_Node(i,4)),' ',''));
        fprintf(fid,'\t from %s;\n',char(BreakerSect_Node(i,2)));
        fprintf(fid,'\t to %s;\n', char(BreakerSect_Node(i,5)));
        fprintf(fid,'\t retry_time 1s;\n');
        fprintf(fid,'\t max_number_of_tries 3;\n');
        if (BreakerOpen(i) == 1) && (~AllClosed)
            fprintf(fid,'\t status OPEN;\n');
        end
        fprintf(fid,'}\n\n\n');
        
    end
end

%Print Switch
if size(SwitchMatrix,1) > 0
    SwitchSect_Node(:,2)=SecFromTo(BreakerN+1:BreakerN+SwitchN,2);
    if AllClosed
        GlmFileName=strcat(glm_dir_name,'\','Switches_',FeederName,'_Closed.glm')
    else
        GlmFileName=strcat(glm_dir_name,'\','Switches_',FeederName,'_O-C.glm') %'_O-C' tells making_header not to include it
    end
    fid = fopen(GlmFileName,'wt');
    fprintf(fid,strcat('//**Switches_',FeederName,':%s\n\n\n'),'');
    
    for i=1:SwitchN
        %Switch
        fprintf(fid,'object switch {\n');
        fprintf(fid,'\t name Switch_%s;\n',char(SW_UniqID(i)));
        fprintf(fid,'\t phases %s;\n',strrep(char(SwitchSect_Node(i,4)),' ',''));
        fprintf(fid,'\t from %s;\n',char(SwitchSect_Node(i,2)));
        fprintf(fid,'\t to %s;\n',char(SwitchSect_Node(i,5)));%% TO NEW CREATED NODE
        if strcmp(SwitchSect_Node(i,4),'ABCN')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_A_state OPEN;\n'); %***Original state is OPEN if switchOpen==1
                fprintf(fid,'\t phase_B_state OPEN;\n');
                fprintf(fid,'\t phase_C_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_A_state CLOSED;\n');
                fprintf(fid,'\t phase_B_state CLOSED;\n');
                fprintf(fid,'\t phase_C_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'ABC')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_A_state OPEN;\n'); %***Original state is OPEN if switchOpen==1
                fprintf(fid,'\t phase_B_state OPEN;\n');
                fprintf(fid,'\t phase_C_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_A_state CLOSED;\n');
                fprintf(fid,'\t phase_B_state CLOSED;\n');
                fprintf(fid,'\t phase_C_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'ABN')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_A_state OPEN;\n'); %***Original state is OPEN if switchOpen==1
                fprintf(fid,'\t phase_B_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_A_state CLOSED;\n');
                fprintf(fid,'\t phase_B_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'AB')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_A_state OPEN;\n'); %***Original state is OPEN if switchOpen==1
                fprintf(fid,'\t phase_B_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_A_state CLOSED;\n');
                fprintf(fid,'\t phase_B_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'ACN')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_A_state OPEN;\n');
                fprintf(fid,'\t phase_C_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_A_state CLOSED;\n');
                fprintf(fid,'\t phase_C_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'AC')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_A_state OPEN;\n');
                fprintf(fid,'\t phase_C_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_A_state CLOSED;\n');
                fprintf(fid,'\t phase_C_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'BCN')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_B_state OPEN;\n');
                fprintf(fid,'\t phase_C_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_B_state CLOSED;\n');
                fprintf(fid,'\t phase_C_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'BC')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_B_state OPEN;\n');
                fprintf(fid,'\t phase_C_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_B_state CLOSED;\n');
                fprintf(fid,'\t phase_C_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'AN')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_A_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_A_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'A')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_A_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_A_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'BN')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_B_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_B_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'B')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_B_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_B_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'CN')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_C_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_C_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        elseif strcmp(cellstr(SwitchSect_Node(i,4)),'C')
            if (SwitchOpen(i) == 1) && (~AllClosed)
                fprintf(fid,'\t phase_C_state OPEN;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            else
                fprintf(fid,'\t phase_C_state CLOSED;\n');
                fprintf(fid,'\t operating_mode INDIVIDUAL;\n');
                fprintf(fid,'}\n');
            end
        end
    end
    
    fprintf(fid,strcat('//**End Switches_',FeederName,'** %s \n\n\n'));
  
    save Switches_Closed;
end
%% Print out Regulator
if size(RegulatorMatrix,1) > 0
    
    GlmFileName_reg=strcat(glm_dir_name,'\','Regulators_',FeederName,'_Closed.glm')
    
    fid = fopen(GlmFileName_reg,'wt');
    fprintf(fid,strcat('//**Regulators_',FeederName,':%s\n\n\n'),'');
    
    % Regulator Configuration
    
    for m=1:RegulatorN
        for n=1:RegConfigN
            if strcmp(RegType(m),RegCofigType(n))
                fprintf(fid,'object regulator_configuration {\n');
                fprintf(fid,'\t name Reg_Config_%s;\n',num2str(n));
                RegulatorSect_Node(m,5)=cellstr(num2str(n));
                RegulatorSect_Node(m,6)=RegCofigType(n);
                
                if strcmp(RegConnect(m),'YG')
                    fprintf(fid,'\t connect_type 1;\n');
                    
                end
                
                fprintf(fid,'\t band_center %d;\n',RegulatorMatrix(m,14));
                fprintf(fid,'\t band_width %d;\n',RegulatorMatrix(m,23));
                fprintf(fid,'\t time_delay 30.0;\n');
                fprintf(fid,'\t raise_taps 16;\n');
                fprintf(fid,'\t lower_taps 16;\n');
                fprintf(fid,'\t  current_transducer_ratio %d;\n',RegConfigMatrix(n,9));
                fprintf(fid,'\t  power_transducer_ratio %d;\n',RegConfigMatrix(n,8));
                
                fprintf(fid,'\t  compensator_r_setting_A %d;\n',RegulatorMatrix(m,17));
                fprintf(fid,'\t  compensator_r_setting_B %d;\n',RegulatorMatrix(m,18));
                fprintf(fid,'\t  compensator_r_setting_C %d;\n',RegulatorMatrix(m,19));
                fprintf(fid,'\t  compensator_x_setting_A %d;\n',RegulatorMatrix(m,20));
                fprintf(fid,'\t  compensator_x_setting_B %d;\n',RegulatorMatrix(m,21));
                fprintf(fid,'\t  compensator_x_setting_C %d;\n',RegulatorMatrix(m,22));
                
                fprintf(fid,'\t  CT_phase "%s";\n',char(RegulatorText(m+1,3)));
                fprintf(fid,'\t  PT_phase "%s";\n',char(RegulatorText(m+1,3)));
                
                fprintf(fid,'\t regulation 0.10;\n');
                fprintf(fid,'\t Control LINE_DROP_COMP;\n');
                fprintf(fid,'\t control_level INDIVIDUAL;\n');
                fprintf(fid,'\t Type B;\n');
                
                fprintf(fid,'\t tap_pos_A %d;\n',RegulatorMatrix(m,11) );
                fprintf(fid,'\t tap_pos_B %d;\n',RegulatorMatrix(m,12) );
                fprintf(fid,'\t tap_pos_C %d;\n',RegulatorMatrix(m,13) );
                
                fprintf(fid,'}\n\n\n\n');
                
            end
        end
    end
    
    % Object Regulator Change to NEW From Node
    RegulatorSect_Node(:,2)=SecFromTo(BreakerN+SwitchN+1:BreakerN+SwitchN+RegulatorN,2);
    
    for i=1:RegulatorN
        %Switch
        fprintf(fid,'object regulator {\n');
        fprintf(fid,'\t name Regulator_%s;\n',char(Reg_UniqID(i)));
        fprintf(fid,'\t phases %s;\n',strrep(char(RegulatorSect_Node(i,4)),' ',''));
        fprintf(fid,'\t from %s;\n',char(RegulatorSect_Node(i,2)));
        fprintf(fid,'\t to %s;\n',char(RegulatorSect_Node(i,7)));           %To new created node
        fprintf(fid,'\t configuration Reg_Config_%s;\n',char(RegulatorSect_Node(i,5)));
        fprintf(fid,'}\n\n\n');
    end
    
    fprintf(fid,strcat('//**End Regulator_',FeederName,'** %s \n\n\n'));
    
    save Regulator;
end

%% Print out Transformers
if size(XfmrMatrix,1) > 0
    GlmFileName_Xfmr=strcat(glm_dir_name,'\','Transformers_',FeederName,'_Closed.glm')
    fid = fopen(GlmFileName_Xfmr,'wt');
    fprintf(fid,strcat('//**Transformers_',FeederName,':%s\n\n\n'),'');
    
    % Transformer Configuration
    for m=1:XfmrN
        for n=1:XfmrConfigN
            if strcmp(XfmrType(m),XfmrCofigType(n))
                XfmrSect_Node(m,5)=cellstr(num2str(n));
                XfmrSect_Node(m,6)=XfmrCofigType(n);
                low_voltage(m,1) = XfmrConfigMatrix(n,3)*1000/sqrt(3);
                if m==1
                    uniqueXfmr = 1;
                else
                    uniqueXfmr = ~ismember(str2num(cell2mat(XfmrSect_Node(m,5))),str2num(cell2mat(XfmrSect_Node(1:m-1,5))));
                end
                if uniqueXfmr
                    fprintf(fid,'object transformer_configuration {\n');
                    fprintf(fid,'\t name Xfmr_Config_%s;\n',num2str(n));
                    
                    if (strcmp(XfmrConnect_high(m),'YG') == 1) && (strcmp(XfmrConnect_low(m),'YG') == 1)
                        fprintf(fid,'\t connect_type WYE_WYE;\n');
                    else
                        fprintf(fid,'\t connect_type DELTA_GWYE;\n');
                    end
                    
                    if XfmrConfigMatrix(n,3)<2
                        fprintf(fid,'\t install_type POLETOP;\n');
                    else
                        fprintf(fid,'\t install_type PADMOUNT;\n');
                    end
                    
                    fprintf(fid,'\t primary_voltage %d;\n',XfmrConfigMatrix(n,2)*1000/sqrt(3));
                    fprintf(fid,'\t secondary_voltage %d;\n',XfmrConfigMatrix(n,3)*1000/sqrt(3));
                    fprintf(fid,'\t power_rating %d;\n',XfmrConfigMatrix(n,4));
                    %fprintf(fid,'\t resistance %d;\n',XfmrConfigMatrix(n,6)/XfmrConfigMatrix(n,4));
                    fprintf(fid,'\t impedance %d+%dj;\n',XfmrConfigMatrix(n,6)/XfmrConfigMatrix(n,4),XfmrConfigMatrix(n,5)/XfmrConfigMatrix(n,4));
                    fprintf(fid,'\t no_load_loss %d;\n',XfmrConfigMatrix(n,9));
                    
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
        fprintf(fid,'\t name Trafo_%s;\n',char(Xfmr_UniqID(i)));
        fprintf(fid,'\t phases %s;\n',strrep(char(XfmrSect_Node(i,4)),' ',''));
        fprintf(fid,'\t from %s;\n',char(XfmrSect_Node(i,2)));
        fprintf(fid,'\t to %s;\n',char(XfmrSect_Node(i,7)));           %To new created node
        fprintf(fid,'\t configuration Xfmr_Config_%s;\n',char(XfmrSect_Node(i,5)));
        fprintf(fid,'}\n\n\n');
        index = find(strcmp(SecFromTo(:,5), char(XfmrSect_Node(i,7))));
        SecFromTo(index,6) = num2cell(low_voltage(i,1));
        
    end
    
    fprintf(fid,strcat('//**End Transformers_',FeederName,'** %s \n\n\n'));
    
    save Transformers;
end
%% Print OUT Fuse
if size(FuseMatrix,1) > 0
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
        
        fprintf(fid,'\t name FUSEs_%s;\n',char(Fuse_UniqID(i)));
        
        fprintf(fid,'\t phases "%s";\n',strrep(char(FuseSect_Node(i,4)),' ',''));
        
        fprintf(fid,'\t from %s;\n',char(FuseSect_Node(i,2)));
        fprintf(fid,'\t to %s;\n', char(FuseSect_Node(i,6)));% connect to new fuse node
        fprintf(fid,'\t current_limit %d A;\n',FuseCutoffAmp(i));
        fprintf(fid,'\t mean_replacement_time %3d ;\n',FuseMatrix(i,20)*3600);
        
        
        if (FuseIsOpen(i)==0) || (~AllClosed)
            
            fprintf(fid,'\t phase_A_status GOOD;\n');
            fprintf(fid,'\t phase_B_status GOOD;\n');
            fprintf(fid,'\t phase_C_status GOOD;\n');
        else
            
            fprintf(fid,'\t phase_A_status BLOWN;\n');%Original state is BLOWN if FuseOpen==1
            fprintf(fid,'\t phase_B_status BLOWN;\n');
            fprintf(fid,'\t phase_C_status BLOWN;\n');
        end
        fprintf(fid,'\t repair_dist_type NONE;\n');
        fprintf(fid,'}\n\n\n');
        
    end
    
    fprintf(fid,strcat('//**End Fuses_',FeederName,'** %s \n\n\n'));
    
    save Fuses_Good;
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

save(strcat(FeederName,'_SectionFromTo'),'SecFromTo')

end
