function Convert_synergi2glm(conn_model, conn_warehouse, Feedername, AllClosed)

%Feedername = 'SPU125'
%AllClosed = true
NominalVolt=7970;
%databaseName = '20120206_Pullman'
%% setting up connection with SynerGEE DataBase
% disp('Connect to database')
% conn = database(databaseName,'','');
%% Query for Sections
selectquery = 'SELECT * FROM InstSection';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
InstSection = curs.Data;
%InstSection = select(conn,selectquery);
%InstSection(1:20,:);
row = strcmp(InstSection(:,2),Feedername);
feeder_Section = InstSection(row,:);
% remove spaces from phases ex: "A  N" -> "AN"
feeder_Section(:,5) = strrep(feeder_Section(:,5),' ','');
% feeder_nodes = unique(cat(1,feeder_Section(:,3),feeder_Section(:,4))); %
feeder_sectionId = feeder_Section(:,1);

%% Query for Loads
selectquery = 'SELECT * FROM Loads';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Loads = curs.Data;
%Loads = select(conn,selectquery);
row = find(ismember(Loads(:,1),feeder_sectionId));
feeder_Loads = Loads(row,:);
if length(row) < 1
    contains_loads = false;
else
    contains_loads = true;
end
%% Large Customers
selectquery = 'SELECT * FROM InstLargeCust';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Large_customers = curs.Data;
%Loads = select(conn,selectquery);
row = find(ismember(Large_customers(:,1),feeder_sectionId));
feeder_Large_customers = Large_customers(row,:);
if length(row) < 1
    contains_Large_customers = false;
else
    contains_Large_customers = true;
end
%% Query for Large Capacitors
selectquery = 'SELECT * FROM Instcapacitors';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Capacitors = curs.Data;
%Capacitors = select(conn,selectquery);

row = find(ismember(Capacitors(:,1),feeder_sectionId));
feeder_Capacitor = Capacitors(row,:);
if length(row) < 1
    contains_caps = false;
else
    contains_caps = true;
end
%% Query for Switches
selectquery = 'SELECT * FROM InstSwitches';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Switches = curs.Data;
%Switches = select(conn,selectquery);
row = find(ismember(Switches(:,1),feeder_sectionId));
feeder_Switches = Switches(row,:);
if length(row) < 1
    contains_switches = false;
else
    contains_switches = true;
end

%% Query for Sectionalizers
selectquery = 'SELECT * FROM InstSectionalizers';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Sectionalizers = curs.Data;
%Switches = select(conn,selectquery);
row = find(ismember(Sectionalizers(:,1),feeder_sectionId));
feeder_Sectionalizers = Sectionalizers(row,:);
if length(row) < 1
    contains_sectionalizers = false;
else
    contains_sectionalizers = true;
end
%% Query for Breakers
selectquery = 'SELECT * FROM InstBreakers';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Breakers = curs.Data;
%Breakers = select(conn,selectquery);
row = find(ismember(Breakers(:,1),feeder_sectionId));
feeder_Breakers = Breakers(row,:);
if length(row) < 1
    contains_breakers = false;
else
    contains_breakers = true;
    % remove spaces from phases ex: "A  N" -> "AN"
    feeder_Breakers(:,44) = strrep(feeder_Breakers(:,44),' ','');
end
%% Query for Regulators
selectquery = 'SELECT * FROM InstRegulators';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Regulators = curs.Data;
%Regulators = select(conn,selectquery);
row = find(ismember(Regulators(:,1),feeder_sectionId));
feeder_Regulators = Regulators(row,:);
if length(row) < 1
    contains_regulators = false;
else
    contains_regulators = true;
    % remove spaces from phases ex: "A  N" -> "AN"
    feeder_Regulators(:,3) = strrep(feeder_Regulators(:,3),' ','');
end
%% Query for Fuses
selectquery = 'SELECT * FROM InstFuses';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Fuses = curs.Data;
row = find(ismember(Fuses(:,1),feeder_sectionId));
feeder_Fuses = Fuses(row,:);
if length(row) < 1
    contains_fuses = false;
else
    contains_fuses = true;
    % remove spaces from phases ex: "A  N" -> "AN"
    feeder_Fuses(:,11) = strrep(feeder_Fuses(:,11),' ',''); 
end
%% Query for Transformers
selectquery = 'SELECT * FROM InstPrimaryTransformers';
curs = exec(conn_model,selectquery);
curs = fetch(curs);
Xfmrs = curs.Data;
%Fuses = select(conn,selectquery);
row = find(ismember(Xfmrs(:,1),feeder_sectionId));
feeder_Xfmrs = Xfmrs(row,:);
if length(row) < 1
    contains_Xfmrs = false;
else
    contains_Xfmrs = true;
end
% close(conn)
%% Query for Conductor Warehouse
% conn = database('Warehouse','','');
selectquery = 'SELECT * FROM DevConductors';
curs = exec(conn_warehouse,selectquery);
curs = fetch(curs);
conductors_config_new = curs.Data;
conductors_config = [num2cell(1:size(conductors_config_new,1))' conductors_config_new];
%% Query for Regulator Config
selectquery = 'SELECT * FROM DevRegulators';
curs = exec(conn_warehouse,selectquery);
curs = fetch(curs);
Regulators_config = curs.Data;
%% Query for Transoformer Config
selectquery = 'SELECT * FROM DevTransformers';
curs = exec(conn_warehouse,selectquery);
curs = fetch(curs);
Transformers_config = curs.Data;

%% creating sub directory

% currentFolder = pwd;
% folderName = strcat(Feedername,'_data');
% model_dir_name = strcat(pwd,'\',folderName);
% mkdir(model_dir_name);
% fileattrib(folderName,'+w');

%% writing feeder data from SynerGEE Database
% disp('Writing .xlsx data to :')
% disp(model_dir_name)
% writetable(cell2table(feeder_Loads), strcat(model_dir_name,'\',Feedername,'_Load.xlsx'))
% writetable(cell2table(feeder_Section), strcat(model_dir_name,'\',Feedername,'_Section.xlsx'))
% writetable(cell2table(feeder_Capacitor), strcat(model_dir_name,'\',Feedername,'_Capacitor.xlsx'))
% writetable(cell2table(feeder_Switches), strcat(model_dir_name,'\',Feedername,'_Switches.xlsx'))
% writetable(cell2table(feeder_Breakers), strcat(model_dir_name,'\',Feedername,'_Breakers.xlsx'))
% writetable(cell2table(feeder_Regulators), strcat(model_dir_name,'\',Feedername,'_Regulators.xlsx'))
% writetable(cell2table(feeder_Fuses), strcat(model_dir_name,'\',Feedername,'_Fuses.xlsx'))
% writetable(cell2table(feeder_Large_customers), strcat(model_dir_name,'\',Feedername,'_Large_customers.xlsx'))
% writetable(cell2table(feeder_Xfmrs), strcat(model_dir_name,'\',Feedername,'_PrimaryTransformers.xlsx'))

% writetable(cell2table(conductors_config), strcat(model_dir_name,'\','conductor_warehouse.xlsx'))
% writetable(cell2table(Regulators_config), strcat(model_dir_name,'\','regulator_warehouse.xlsx'))
% writetable(cell2table(Transformers_config), strcat(model_dir_name,'\','transformer_warehouse.xlsx'))

% close(conn_warehouse)
%% Writing GLM scripts
glm_folderName = strcat(Feedername,'_glm');
glm_dir_name = strcat(pwd,'\',glm_folderName);
mkdir (glm_folderName);
fileattrib(glm_dir_name,'+w');
disp('Writing .glm files to')
disp(glm_dir_name)
% capacitors
if contains_caps
    disp('Making Caps')
    making_Cap(feeder_Section,feeder_Capacitor,Feedername,NominalVolt,glm_dir_name); 
end
% breakers regulators fuses switches transformers
if contains_breakers || contains_regulators || contains_fuses || contains_switches || contains_Xfmrs || contains_sectionalizers
    disp('Making breakers, regulators, fuses, switches, sectionalizers, xfmrs')
   SecFromTo = making_Breaker_Switch_Regulator_Fuse(feeder_Section,feeder_Switches,feeder_Sectionalizers,feeder_Regulators,Regulators_config,feeder_Fuses,feeder_Breakers,feeder_Xfmrs,Transformers_config,Feedername,NominalVolt,glm_dir_name, AllClosed);
end
% Nodes
disp('Making nodes')
[low_voltage_nodes, low_voltage_nodes_volt]=making_nodes(feeder_Section,Feedername,NominalVolt,glm_dir_name,SecFromTo);
% Large Customer Loads
if contains_Large_customers
    disp('Making large custormer loads')
    making_Large_customers(feeder_Section,feeder_Large_customers,Feedername,NominalVolt,glm_dir_name,low_voltage_nodes,low_voltage_nodes_volt);
end
% Loads
if contains_loads
    disp('Makeing loads')
    making_Load(feeder_Section,feeder_Loads,Feedername,NominalVolt,glm_dir_name,low_voltage_nodes,low_voltage_nodes_volt);
end
% lines OH_UG
disp('Sorting line OH UG')
[contains_UG,OH_line,UG_line,Type_OH,Type_UG]=sorting_line_OH_UG(conductors_config,feeder_Section);
% OH lines
disp('Making OH lines')
[conf_OH_name,conf_OH_phases]=making_OH_Lines(Feedername,glm_dir_name,SecFromTo,OH_line,Type_OH);
% OH line configuration
disp('Making OH line configs')
making_OH_Line_Configuration(conductors_config,Feedername,glm_dir_name,conf_OH_name,conf_OH_phases)
if contains_UG 
    % UG lines
    disp('Making UG lines')
    [conf_UG_name,conf_UG_phases]=making_UG_Lines(Feedername,glm_dir_name,SecFromTo,UG_line,Type_UG);
    % UG Line configuration
    disp('Making UG line configs')
    making_UG_Line_Configuration(conductors_config,Feedername,glm_dir_name,conf_UG_name,conf_UG_phases)
end
% making the main header glm file
making_header(Feedername,glm_dir_name,contains_UG);

clearvars
end
