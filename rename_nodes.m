

function [NewFeeder, SectionIds] = rename_nodes(Feeder)
%% Rename Nodes
% Format: 
%       Node: FeederName_####...-#
%       Section: FromNode->abreviated ToNode
%         If you wanted to get to the indicated node starting at the
%         substation, the numbers before the dash indecate which branch to
%         take anytime a choice is available. 
%         The number following the dash indicates the number of nodes away
%         from the substation.
%         The SectionId 
%   EXAMPLE:
%                      SUB123
%                         |  <-- "SUB123->-1"
%                     SUB123_0-1
% "SUB123_0-1->1-2" --> /   \  <-- "SUB123_0-1->2-2"
%              SUB123_1-2  SUB123_2-2
%      "SUB123_2-2->1-3" -->  /   \   <-- "SUB123_2-2->2-3"
%                    SUB123_21-3  SUB123_22-3

%%% Initialize tree traversal at substation
lvl = 1;
count = 0;
N = length(Feeder.FromNodeId);
NewFeeder = Feeder;
%%% Initialize stacks
lvlstack = zeros(N,1);
Bstack = zeros(N,1);
Jstack = cell(N,1);
Jstack(1) = {''};
found = cell(N,2);
SectionIds = cell(N,2);
%%%
FeederName = Feeder.FeederId(1);
FromNode = FeederName;
sections = ismember(Feeder.FromNodeId, FromNode);
top = 1;
while 1
    if sum(sections) > 1
        if string(Jstack(top)) ~= string(FromNode)
            % New junction node found.
            % Push FromNode to Stack
            top = top +1;
            Jstack(top) = FromNode;
            Bstack(top) = sum(sections);
            lvlstack(top) = lvl;
        elseif string(Jstack(top)) == string(FromNode)
            % Returned to previous junction node.
            % Decrement branch number.
            Bstack(top) = Bstack(top) - 1;
            while Bstack(top) < 1 && top > 1
                top = top -1;
                Bstack(top) = Bstack(top) - 1;
                FromNode = Jstack(top);
                lvl = lvlstack(top);
            end
        end
        if top < 2
            return
        end
        br = Bstack(top);
        % Find ToNode
        sections = ismember(Feeder.FromNodeId, FromNode);
        ToNodes = char(Feeder.ToNodeId(sections));
        ToNode = {strrep(ToNodes(br,:),' ','')};
        % Rename ToNode node.
        count = count + 1;
        found(count,1) = ToNode;
        i = top;
        str = '';
        while i > 1
            str = char(strcat(string(Bstack(i)),str));
            i = i - 1;
        end
        found(count,2) = {char(strcat(FeederName{:}, '_', str, '-', string(lvl)))};
        downstream_sections = ismember(Feeder.FromNodeId, found(count,1));
        upstream_sections = ismember(Feeder.ToNodeId, found(count,1));
        NewFeeder.FromNodeId(downstream_sections)=found(count,2);
        NewFeeder.ToNodeId(upstream_sections)=found(count,2);
        NewFeeder.SectionId(upstream_sections) = {char(strcat(NewFeeder.FromNodeId(upstream_sections),'->',str(end),'-',string(lvl)))};
        SectionIds(count,1) = Feeder.SectionId(upstream_sections);
        SectionIds(count,2) = {char(strcat(NewFeeder.FromNodeId(upstream_sections),'->',str(end),'-',string(lvl)))};
        % Move to next node.
        FromNode = ToNode;
        lvl = lvl + 1;
        sections = ismember(Feeder.FromNodeId, FromNode);
    elseif sum(sections) == 1
        if top < 2
            %return
        end
        br = 1;
        % Find ToNode
        sections = ismember(Feeder.FromNodeId, FromNode);
        ToNodes = char(Feeder.ToNodeId(sections));
        ToNode = {strrep(ToNodes(br,:),' ','')};
        % Rename ToNode node.
        count = count + 1;
        found(count,1) = ToNode;
        i = top;
        str = '';
        while i > 1
            str = char(strcat(string(Bstack(i)),str));
            i = i - 1;
        end
        if isempty(str)
            str = char(string(0));
        end
        found(count,2) = {char(strcat(FeederName{:}, '_', str, '-', string(lvl)))}; % Add new name to array
        downstream_sections = ismember(Feeder.FromNodeId, found(count,1));
        upstream_sections = ismember(Feeder.ToNodeId, found(count,1));
        NewFeeder.FromNodeId(downstream_sections)=found(count,2);% Replace corresponding FronNodes with new name.
        NewFeeder.ToNodeId(upstream_sections)=found(count,2);
        NewFeeder.SectionId(upstream_sections) = {char(strcat(NewFeeder.FromNodeId(upstream_sections),'->','-',string(lvl)))};
        SectionIds(count,1) = Feeder.SectionId(upstream_sections);
        SectionIds(count,2) = {char(strcat(NewFeeder.FromNodeId(upstream_sections),'->','-',string(lvl)))};
        %found(count,2) = 
        % Move to next node.
        FromNode = ToNode;
        lvl = lvl + 1;
        sections = ismember(Feeder.FromNodeId, FromNode);
    elseif sum(sections) < 1
        
        if top < 2
            return
        end
        % Reached leaf node. Go back to previous junction node.
        FromNode = Jstack(top);
        lvl = lvlstack(top);
       %top = top - 1;
        sections = ismember(Feeder.FromNodeId, FromNode);
    end
    
end
end










