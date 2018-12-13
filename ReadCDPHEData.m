
clear all

mos = {'ja','fe','ma','ap','my','jn','jl','ag','sp','oc','nv','dc'}; %List of short month names for filenaming
params = [88101, 81102];
yrs = [2018];

clearvars filename delimiter formatSpec fileID dataArray ans;
for p=params
    for yr=yrs
        for z=1:12
            m = mos{z};
            
            %Read the data
            filename = [m num2str(yr) '_' num2str(p) 'dat.txt'];
            delimiter = '\t';
            %Format for each line of text:
            formatSpec = '%q%[^\n\r]';
            %Open the text file.
            fileID = fopen(filename,'r');
            if fileID==-1
                continue
            end
            
            %Read columns of data according to the format.
            dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
            %Close the text file.
            fclose(fileID);
            %Create output variable
            tempdata = [dataArray{1:end-1}];
            
            for i = 3:size(tempdata,1)%each day
                splitRows = splitlines(tempdata(i));
                headers = cellstr(split(splitRows(3))');
                for j=4:27%each hour
                    tempRow = str2double(strsplit(splitRows(j),'\t','CollapseDelimiters',false));
                    
                    if exist('dayTable','var')~=1
                        dayTable = array2table(tempRow,'VariableNames',cellstr(headers));
                    else
                        temp = array2table(tempRow,'VariableNames',cellstr(headers));
                        dayTable = [dayTable;temp];
                    end
                end%Loop through hours of data
                
                %Add variable tracking day
                dayTable.day = ones(size(dayTable,1),1).*(i-2);
                
                if exist('monthTable','var')~=1
                    monthTable = dayTable;
                else
                    %Need to check if stations appeared or disappeared
                    if length(monthTable.Properties.VariableNames)<length(dayTable.Properties.VariableNames)
                        for vn = 1:size(dayTable,2)
                            if ~any(strcmp(dayTable.Properties.VariableNames{vn}, monthTable.Properties.VariableNames))
                                monthTable.(dayTable.Properties.VariableNames{vn})=NaN(size(monthTable,1),1);
                            end
                        end
                    elseif length(monthTable.Properties.VariableNames)>length(dayTable.Properties.VariableNames)
                        for vn = 1:size(monthTable,2)
                            if ~any(strcmp(monthTable.Properties.VariableNames{vn}, dayTable.Properties.VariableNames))
                                dayTable.(monthTable.Properties.VariableNames{vn})=NaN(size(dayTable,1),1);
                            end
                        end
                    end
                    monthTable = [monthTable;dayTable];
                end
                clear dayTable
            end%loop through days of data
            
            %Add variable tracking month
            monthTable.month = ones(size(monthTable,1),1).*z;
            
            if exist('yearTable','var')~=1
                yearTable = monthTable;
            else
                %Need to check if stations appeared or disappeared
                if length(monthTable.Properties.VariableNames)<length(yearTable.Properties.VariableNames)
                    for vn = 1:size(yearTable,2)
                        if ~any(strcmp(yearTable.Properties.VariableNames{vn}, monthTable.Properties.VariableNames))
                            monthTable.(yearTable.Properties.VariableNames{vn})=NaN(size(monthTable,1),1);
                        end
                    end
                elseif length(monthTable.Properties.VariableNames)>length(yearTable.Properties.VariableNames)
                    for vn = 1:size(monthTable,2)
                        if ~any(strcmp(monthTable.Properties.VariableNames{vn}, yearTable.Properties.VariableNames))
                            yearTable.(monthTable.Properties.VariableNames{vn})=NaN(size(yearTable,1),1);
                        end
                    end
                end
                yearTable = [yearTable;monthTable];
            end
            clear monthTable
        end
        
        %Check to make sure that some data was found
        if exist('yearTable','var')~=1
            warning('No data found for this combination of parameters!!');
            continue
        end
        
        %Add variable tracking year
        yearTable.year = ones(size(yearTable,1),1).*yr;
        
        %Fix for CDPHE being dumb
        yearTable.hour(yearTable.hour==0)=24;
        
        %Add excel datetime column
        yearTable.DT = exceltime(datetime(yearTable.year,yearTable.month,yearTable.day,yearTable.hour,0,0));
        
        %Save the file as a CSV with unique names for each year and parameter
        writetable(yearTable,[num2str(yr) '_' num2str(p) 'datatab.csv'])
        clear yearTable
    end
end
disp('Done!')
