
function  [contains_UG,OH_line,UG_line,Type_OH,Type_UG]=sorting_line_OH_UG(dir_name,FeederName,SecFromTo)


% load('SectionFromTo.mat');
%load(strcat(FeederName,'_SectionFromTo.mat'));
[Node_feeder,Node_feeder_text]=xlsread(strcat(dir_name,'\',FeederName,'_Section.xlsx'));
[Conductor_Data,Conductor_type]=xlsread(strcat(dir_name,'\','conductor_warehouse.xlsx'));

Node_feeder_text(1,:)=[];
Node_feeder_text(:,9:26)=num2cell(Node_feeder(:,1:18));

DIM=size(Node_feeder_text);
a=1;
j=1;
for i=1:DIM(1,1)
         l= strfind(Node_feeder_text(i,7),'CN');
      if iscellstr(Node_feeder_text(i,6))~=0
         k = strfind(Node_feeder_text(i,6),'CircuitSegmentBank');
          if cell2mat(k)==1;
            if isempty(cell2mat(l))==1;
               OH_index(j,1)=i;
               j=j+1;
            end
          end
      end
      
      
     if strcmp(Node_feeder_text(i,6),Node_feeder_text(i,1))
            if strcmp(Node_feeder_text(i,5),'ABCN')
             OH_index(j,1)=i;
             j=j+1;
             i=i+1;
            end
     end
    

 end


for i=1:length(OH_index)
    OH_line(i,:)=Node_feeder_text(OH_index(i),:);
end

UG_index(:,1)=linspace(1,DIM(1,1),DIM(1,1));
UG_index(OH_index,:)=[];
UG_line = cell(0,0);
for i=1:length(UG_index)
 UG_line(i,:)=Node_feeder_text(UG_index(i),:);
end


 %% conductor type
 Type_OH_phase = cell(0,0);
 Type_OH_neutral = cell(0,0);
 Type_UG_phase = cell(0,0);
 Type_UG_neutral = cell(0,0);
 Conductor_type(2:end,1)=num2cell(Conductor_Data(:,1));
 Conductor_type(2:end,4:13)=num2cell(Conductor_Data(:,4:13));
 
 
 cond_type=Conductor_type(:,1);
 cond_name=Conductor_type(:,2);
 
for i=1:length(OH_index)
     for j=1:length(cond_name)
        if (strcmp((OH_line(i,7)),cond_name(j))==1)
         Type_OH_phase(i,1)=cond_type(j);
        end
     end
end
for i=1:length(OH_index)
     for j=1:length(cond_name)
        if (strcmp((OH_line(i,8)),cond_name(j))==1)
         Type_OH_neutral(i,1)=cond_type(j);
        elseif (isempty(OH_line{i,8})==1)
         Type_OH_neutral(i,1)=Type_OH_phase(i);
        end
     end
end
   
 for i=1:length(UG_index)
     for j=1:length(cond_name)
        if (strcmp((UG_line(i,7)),cond_name(j))==1)
         Type_UG_phase(i,1)=cond_type(j);
        end
     end
 end
 for i=1:length(UG_index)
     for j=1:length(cond_name)
        if (strcmp((UG_line(i,8)),cond_name(j))==1)
         Type_UG_neutral(i,1)=cond_type(j);
         elseif (isempty(UG_line{i,8})==1)
         Type_UG_neutral(i,1)=Type_UG_phase(i);
        end
     end
 end

 strcat(FeederName,'_Feeder_Lines_OH')
 %save('Feeder_Lines_OH','OH_line','Type_OH_neutral','Type_OH_phase','OH_index')
 %save(strcat(FeederName,'_Feeder_Lines_OH'),'OH_line','Type_OH_neutral','Type_OH_phase','OH_index')
 if UG_index > 0
    %save('Feeder_Lines_UG','UG_line','Type_UG_neutral','Type_UG_phase','UG_index')
    %save(strcat(FeederName,'_Feeder_Lines_UG'),'UG_line','Type_UG_neutral','Type_UG_phase','UG_index')
    contains_UG = 1;
 else
    contains_UG = 0;
 end
 Type_OH = [Type_OH_phase, Type_OH_neutral];
 Type_UG = [Type_UG_phase, Type_UG_neutral];
end 
 
 
 
 
 