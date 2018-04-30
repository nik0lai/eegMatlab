function structree(structure,file_name);
%STRUCTREE Prints to a file the fields of a structure in tree form.
%
%    STRUCTREE(STRUCTURE,FILE_NAME) prints all the fieldnames of the
%    specified structure in a file. By default, the file will be saved 
%    in the Matlab's currrent directory. 

%    2004Apr23  Created by Juan E. Vega



level=1;                                                            %variable initialization
row=[1 1];
structure(level,1).data=structure;                                  %structure initialization
fid = fopen(file_name,'w');                                        %open file

while ~isequal(level,0);                                                   
    flag=isa(structure(level,1).data,'struct'); %check that current structure is really a structure
    if (flag==1);                                                    
        if(row(level)==1);  %do this only if you are accesing this level for the first time
            Temp_names=fieldnames(structure(level,1).data); %get field names        
            Temp_size=size(Temp_names);                     %get number of fields
            Directory_size(level)=Temp_size(1);             %store number of fields
            Directory_names(1:Directory_size(level),level)=Temp_names;  %store field names in corresponding level
        end
        Display_name=Directory_names{row(level),level}; %Change field name from cell to arrray
        for index= 1:level-1;      %add necessary tabs
            fprintf(fid,'\t|');
        end
        fprintf(fid,'---');
        fprintf(fid,'%s\n',Display_name); %Write name to file
        level=level+1;                     %Go up one level
        row(level+1)=1;                    %Initialize row variable
        structure(level,1).data=structure(level-1,1).data.(Display_name);  %Update current structure
    else
        level=level-1;  %If current sutructure is not really a structure go down one level
        row(level)=row(level)+1;     %Go to next row
        feedline=0;
        while (row(level)>Directory_size(level));  %Do this if row number exceeds the number of fields
            level=level-1;  %Go down one level
            %for index= 1:level-1;      %add necessary tabs
             %   fprintf(fid,'\t|');
             %end
            if(feedline==0)
                fprintf(fid,'\n');
                feedline=1;
            end
            if (level==0); 
                break;
            end
            row(level+1)=1;  
            row(level)=row(level)+1;
        end
        if (level>1);
            structure(level,1).data=getfield(structure(level-1,1).data,Directory_names{row(level-1),level-1}); %Update structure
        end 
        
    end
end
status = fclose(fid);  %Close file