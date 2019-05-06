
clc
clearvars

Feedername = 'TUR117'
Feedername = 'SPU124'
NonimalVolt=7970;

%% setting up connection with SynerGEE DataBase
conn = database('20120206_Pullman','','');
selectquery = 'SELECT * FROM InstSection';
curs = exec(conn,selectquery)
curs = fetch(curs)
InstSection = curs.Data;
%InstSection = select(conn,selectquery);
InstSection(1:20,:);
row = find(strcmp(InstSection(:,2),Feedername));
row = strcmp(InstSection(:,2),Feedername);
feeder_Section = InstSection(row,:);
feeder_Section(:,5) = strrep(feeder_Section(:,5),' ','');
feeder_nodes = unique(cat(1,feeder_Section(:,3),feeder_Section(:,4)));
feeder_sectionId = feeder_Section(:,1);

%% Query to get data from Database
selectquery = 'SELECT * FROM Loads';
curs = exec(conn,selectquery)
curs = fetch(curs)
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
curs = exec(conn,selectquery)
curs = fetch(curs)
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
curs = exec(conn,selectquery)
curs = fetch(curs)
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
curs = exec(conn,selectquery)
curs = fetch(curs)
Switches = curs.Data;
%Switches = select(conn,selectquery);
row = find(ismember(Switches(:,1),feeder_sectionId));
feeder_Switches = Switches(row,:);
if length(row) < 1
    contains_switches = false;
else
    contains_switches = true;
end
%% Query for Breakers
selectquery = 'SELECT * FROM InstBreakers';
curs = exec(conn,selectquery)
curs = fetch(curs)
Breakers = curs.Data;
%Breakers = select(conn,selectquery);
row = find(ismember(Breakers(:,1),feeder_sectionId));
feeder_Breakers = Breakers(row,:);
feeder_Breakers(:,44) = strrep(feeder_Breakers(:,44),' ','');
if length(row) < 1
    contains_breakers = false;
else
    contains_breakers = true;
end
%% Query for Regulators
selectquery = 'SELECT * FROM InstRegulators';
curs = exec(conn,selectquery)
curs = fetch(curs)
Regulators = curs.Data;
%Regulators = select(conn,selectquery);
row = find(ismember(Regulators(:,1),feeder_sectionId));
feeder_Regulators = Regulators(row,:);
feeder_Regulators(:,3) = strrep(feeder_Regulators(:,3),' ','');
if length(row) < 1
    contains_regulators = false;
else
    contains_regulators = true;
end
%% Query for Fuses
selectquery = 'SELECT * FROM InstFuses';
curs = exec(conn,selectquery)
curs = fetch(curs)
Fuses = curs.Data;
%Fuses = select(conn,selectquery);
row = find(ismember(Fuses(:,1),feeder_sectionId));
feeder_Fuses = Fuses(row,:);
feeder_Fuses(:,11) = strrep(feeder_Fuses(:,11),' ','');
if length(row) < 1
    contains_fuses = false;
else
    contains_fuses = true;
end
%% Query for Transformers
selectquery = 'SELECT * FROM InstPrimaryTransformers';
curs = exec(conn,selectquery)
curs = fetch(curs)
Xfmrs = curs.Data;
%Fuses = select(conn,selectquery);
row = find(ismember(Xfmrs(:,1),feeder_sectionId));
feeder_Xfmrs = Xfmrs(row,:);
if length(row) < 1
    contains_Xfmrs = false;
else
    contains_Xfmrs = true;
end
close(conn)
%% Query for Conductor Warehouse
conn = database('Warehouse','','');
selectquery = 'SELECT * FROM DevConductors';
curs = exec(conn,selectquery)
curs = fetch(curs)
conductors_config = curs.Data;
%% Query for Regulator Config
selectquery = 'SELECT * FROM DevRegulators';
curs = exec(conn,selectquery)
curs = fetch(curs)
Regulators_config = curs.Data;
%% Query for Transoformer Config
selectquery = 'SELECT * FROM DevTransformers';
curs = exec(conn,selectquery)
curs = fetch(curs)
Transformers_config = curs.Data;

%% creating sub directory

currentFolder = pwd;
folderName = strcat(Feedername,'_data');
model_dir_name = strcat(pwd,'\',folderName);
mkdir(model_dir_name);
fileattrib(folderName,'+w');

%% writing feeder data from SynerGEE Database
disp('Writing .xlsx data to :')
disp(model_dir_name)
writetable(cell2table(feeder_Loads), strcat(model_dir_name,'\',Feedername,'_Load.xlsx'))
writetable(cell2table(feeder_Section), strcat(model_dir_name,'\',Feedername,'_Section.xlsx'))
writetable(cell2table(feeder_Capacitor), strcat(model_dir_name,'\',Feedername,'_Capacitor.xlsx'))
writetable(cell2table(feeder_Switches), strcat(model_dir_name,'\',Feedername,'_Switches.xlsx'))
writetable(cell2table(feeder_Breakers), strcat(model_dir_name,'\',Feedername,'_Breakers.xlsx'))
writetable(cell2table(feeder_Regulators), strcat(model_dir_name,'\',Feedername,'_Regulators.xlsx'))
writetable(cell2table(feeder_Fuses), strcat(model_dir_name,'\',Feedername,'_Fuses.xlsx'))
writetable(cell2table(feeder_Large_customers), strcat(model_dir_name,'\',Feedername,'_Large_customers.xlsx'))
writetable(cell2table(feeder_Xfmrs), strcat(model_dir_name,'\',Feedername,'_PrimaryTransformers.xlsx'))

writetable(cell2table(conductors_config), strcat(model_dir_name,'\','conductor_warehouse.xlsx'))
writetable(cell2table(Regulators_config), strcat(model_dir_name,'\','regulator_warehouse.xlsx'))
writetable(cell2table(Transformers_config), strcat(model_dir_name,'\','transformer_warehouse.xlsx'))

close(conn)
%% Writing GLM scripts
glm_folderName = strcat(Feedername,'_glm');
glm_dir_name = strcat(pwd,'\',glm_folderName);
mkdir (glm_folderName);
fileattrib(glm_dir_name,'+w');
disp('Writing .glm files to \n')
disp(glm_dir_name)
% capacitors
if contains_caps
    making_Cap(model_dir_name,Feedername,NonimalVolt,glm_dir_name);
end
% breakers regulators fuses
if contains_breakers || contains_regulators || contains_fuses
    making_Breaker_Switch_Regulator_Fuse(model_dir_name,Feedername,NonimalVolt,glm_dir_name);
end
% nodes
making_nodes(model_dir_name,Feedername,NonimalVolt,glm_dir_name);
% loads
if contains_Large_customers
    making_Large_customers(model_dir_name,Feedername,NonimalVolt,glm_dir_name);
end
if contains_loads
    making_Load(model_dir_name,Feedername,NonimalVolt,glm_dir_name);
end
% lines OH_UG
contains_UG = sorting_line_OH_UG(model_dir_name,Feedername);
% OH lines
making_OH_Lines(model_dir_name,Feedername,glm_dir_name)
% OH line configuration
making_OH_Line_Configuration(model_dir_name,Feedername,glm_dir_name)
if contains_UG 
    % UG lines
    making_UG_Lines(model_dir_name,Feedername,glm_dir_name)
    % UG Line configuration
    making_UG_Line_Configuration(model_dir_name,Feedername,glm_dir_name)
end
%making the main header glm file
making_header(Feedername,glm_dir_name,contains_UG);
