
function [low_voltage_nodes, low_voltage_nodes_volt]=making_nodes(feeder_Section,FeederName,NonimalVolt,glm_dir_name,SecFromTo)

%load(strcat(FeederName,'_SectionFromTo.mat'));
%load('SectionFromTo.mat');
% [Node_feeder,Node_feeder_text]=xlsread(strcat(dir_name,'\',FeederName,'_Section.xlsx'));
[r,c] = size(feeder_Section);
Node_feeder_text = cell(r+1,c); % first row not needed. Only added to make new code compatible with old
Node_feeder_text(2:end,:) = feeder_Section;
%% Plotting Feeder Topology and getting downstream low voltage nodes on Transformer secondary
SecFromTo_modified = SecFromTo;
Node_from_to_modified = Node_feeder_text(2:end,3:4);

[~, ind] = unique(SecFromTo(:,1));
duplicate_ind = setdiff(1:size(SecFromTo, 1), ind);

for i =1:length(duplicate_ind)
    duplicates= find(strcmp(SecFromTo(:,1),SecFromTo(duplicate_ind(i),1)));
    for j = 1:length(duplicates)-1 % THIS SHOULDN'T WORK: length(duplicates)-1:1
        SecFromTo_modified(duplicates(j+1),3) = SecFromTo(duplicates(j),5);
    end
end


for s = 1:size(SecFromTo_modified,1) % was length(SecFromTo_modified), which measures wrong dimension
    for n=2:size(Node_feeder_text,1)
        if (strcmp(SecFromTo_modified(s,1),Node_feeder_text(n,1))==1)
            if (strcmp(SecFromTo_modified(s,2),Node_feeder_text(n,3))==1)
                Node_from_to_modified(n-1,2) = SecFromTo_modified(s,5);
                Node_from_to_modified(length(Node_from_to_modified)+1,1) = SecFromTo_modified(s,5);
                Node_from_to_modified(length(Node_from_to_modified),2) = SecFromTo_modified(s,3);
            else
                Node_from_to_modified(length(Node_from_to_modified)+1,1) = SecFromTo_modified(s,5);
                Node_from_to_modified(length(Node_from_to_modified),2) = SecFromTo_modified(s,3);
                %Node_from_to_modified(length(Node_from_to_modified)+1,2) = SecFromTo_modified(s,5);
                %Node_from_to_modified(length(Node_from_to_modified)+1,3) = SecFromTo_modified(s,3);
            end
            
        end
    
    end
end


G = digraph(Node_from_to_modified(:,1),Node_from_to_modified(:,2));
Node_names = dfsearch(G,FeederName);
node_numbers = 1:length(Node_names);

% for i =1:length(Node_from_to_modified)
%     index_from = find(strcmp(Node_names,Node_from_to_modified(i,1)));
%     node_numbering(i,1) = node_numbers(index_from);
%     index_to = find(strcmp(Node_names,Node_from_to_modified(i,2)));
%     node_numbering(i,2) = node_numbers(index_to);assads
% end
% G1 = digraph(node_numbering(:,1),node_numbering(:,2));
p = plot(G,'NodeLabel',G.Nodes.Name,'Layout','force');
p.Marker = 's';
p.MarkerSize = 7;
p.NodeColor = 'r';
title(['Network Topology for Feeder: ',FeederName]);


Index = find(contains(SecFromTo_modified(:,5), 'Xfmr'));
low_voltage_nodes ={};
low_voltage_nodes_volt =[];
for i = 1:length(Index)
    downstream_nodes = nearest(G,SecFromTo_modified(Index(i),5),inf);
    low_voltage = SecFromTo_modified(Index(i),6);
    low_voltage_nodes = [low_voltage_nodes;SecFromTo_modified(Index(i),5);downstream_nodes];
    low_voltage_nodes_volt= [low_voltage_nodes_volt;cell2mat(low_voltage);cell2mat(low_voltage)*ones(length(downstream_nodes),1)];
end

highlight(p,low_voltage_nodes,'NodeColor','g');
%% Back to making Nodes
phase_to_node = Node_feeder_text(:,5);
phase_from_node = Node_feeder_text(:,5);
for n = 2:size(Node_feeder_text,1)
    to_node = Node_feeder_text(n,4);
    index_to_node = find(strcmp(Node_feeder_text(1:end,4),to_node)==1);
    if (length(index_to_node)>1)
        str = strings;
        for k = 1:length(index_to_node)
            str = strcat(str,Node_feeder_text(index_to_node(k),5));
        end
        new_phase = sort(unique(char(str)));
        phase_to_node(index_to_node,1) = cellstr(new_phase);       
    end
end

   

from_to_node=[Node_feeder_text(2:end,3);Node_feeder_text(2:end,4)];
from_to_node_phase=[phase_from_node(2:end,1);phase_to_node(2:end,1)];

[only_nodes, only_rows, ic] = unique(from_to_node);

%phase=from_to_node_phase(only_rows);
 
for i=1:length(only_nodes)
    k=2;
    for j=1:length(from_to_node)
        if strcmp(cellstr(only_nodes(i)),cellstr(from_to_node(j))) 
            % This if statement gets run 860532 times and takes 9.6s total 
            % when running the convert on 7 feeders. That is 50% of the
            % total computational time!
            node_info(i,1)=only_nodes(i,1);
            node_info(i,k)=from_to_node_phase(j);
            k=k+1;
        end
    end
end

  s=size(node_info);
  
for i=1:s(1)
    k=1;
    for j=2:s(2)
         if (isempty(cell2mat(node_info(i,j)))==0)
             leng(k,1)=length(char(node_info(i,j)));
             temp_phase(1,k)=node_info(i,j);
             k=k+1;
         end
    end
    [M,I] = max(leng);
    Phase(i,1)=temp_phase(1,I);
    leng=[];
end
 
nodes=node_info(:,1);
phases_nodes=Phase;
  
% Node_phase=[nodes phases_nodes];

GlmFileName=strcat(glm_dir_name,'\','Node_',FeederName,'.glm');
fid = fopen(GlmFileName,'wt');
fprintf(fid,strcat('//**Nodes for',FeederName,':%s\n\n\n'),'');

for i = 1:length(nodes)
    fprintf (fid,'object node {\n');
    fprintf (fid,'\t name %s;\n',char(nodes(i)));
    fprintf (fid,'\t phases %s;\n',strrep(char(phases_nodes(i)),' ',''));
    
    if (~isempty(low_voltage_nodes))
        element_index= find(strcmp(low_voltage_nodes(:,1),nodes(i)));
    else
        element_index=[];
    end
    if (length(element_index)==1) 
        voltage  = low_voltage_nodes_volt(element_index,1);
        fprintf (fid,'\t nominal_voltage %.2f;\n',voltage); %%   %%
        if strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'ABCN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'ABC')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'ABN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);  
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'AB')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'ACN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);   
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'AC')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);    
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'BCN')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);  
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'BC')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);       
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'AN')
                fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);       
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'BN')
           fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);     
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'CN')
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);        
        end
    else
        fprintf (fid,'\t nominal_voltage %.2f;\n',NonimalVolt);
        if strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'ABCN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'ABC')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);        
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'ABN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);       
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'AB')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);       
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'ACN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);      
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'AC')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);      
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'BCN')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);       
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'BC')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);        
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'AN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);      
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'BN')
           fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);   
        elseif strcmp(strrep(cellstr(phases_nodes(i)),' ',''),'CN')
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);     
        end
    end
    if strcmp(cellstr(nodes(i)),FeederName)
       fprintf(fid,'\t bustype SWING;\n');
    else
       fprintf(fid,'\t bustype PQ;\n');
    end
    fprintf(fid,'}\n\n\n'); 
          
end

% regulators switches and fuses


To_node_RFS=SecFromTo(:,5);
[ordered,indices]=sort(To_node_RFS);
ordered_SecFromTo=SecFromTo(indices,:);
nodes_new=ordered_SecFromTo(:,5);
phase_new=ordered_SecFromTo(:,4);

for i = 1:length(nodes_new)
    fprintf (fid,'object node {\n');
    fprintf (fid,'\t name %s;\n',char(nodes_new(i)));
    fprintf (fid,'\t phases %s;\n',strrep(char(phase_new(i)),' ',''));
    
    if (length(low_voltage_nodes)>0)
        element_index= find(strcmp(low_voltage_nodes(:,1),nodes_new(i)));
    else
        element_index=[];
    end
    if (length(element_index)==1) 
        voltage  = low_voltage_nodes_volt(element_index,1);
        fprintf (fid,'\t nominal_voltage %.2f;\n',voltage);
        
        if strcmp(strrep(cellstr(phase_new(i)),' ',''),'ABCN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'ABC')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'ABN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'AB')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'ACN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'AC')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'BCN')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'BC')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'AN')
             fprintf (fid,'\t voltage_A %.2f+0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'BN')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',voltage);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'CN')
             fprintf (fid,'\t voltage_C %.2f+120.0d;\n',voltage);
        end
        
    else
        fprintf (fid,'\t nominal_voltage %.2f;\n',NonimalVolt);
        if strcmp(strrep(cellstr(phase_new(i)),' ',''),'ABCN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'ABC')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'ABN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'AB')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'ACN')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'AC')
            fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'BCN')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'BC')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
            fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'AN')
             fprintf (fid,'\t voltage_A %.2f+0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'BN')
            fprintf (fid,'\t voltage_B %.2f-120.0d;\n',NonimalVolt);
        elseif strcmp(strrep(cellstr(phase_new(i)),' ',''),'CN')
             fprintf (fid,'\t voltage_C %.2f+120.0d;\n',NonimalVolt);
        end
        
    end
    
    fprintf(fid,'\t bustype PQ;\n');
    fprintf(fid,'}\n\n\n');
end


% save('Node_Phases','Node_phase')
% save nodes
%workspace = strcat(FeederName,'_Node_voltages');
%save(workspace,'low_voltage_nodes','low_voltage_nodes_volt')
end


