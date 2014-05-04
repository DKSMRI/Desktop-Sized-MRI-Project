function MRIS
h = 250;
w = 400;
global stg afs nma coma
f = figure('Visible', 'on','color',[.8,.8,.8],'MenuBar','none',...
    'Position', [0, 0, w, h]);
set(f,'Name','MRIS')

movegui(f,'center')

InpF = uicontrol('Style','pushbutton','Position',[w-380, h-180, 90, 30],'String','Select PSD:', ...
    'Callback',@InpFfn);
Inptext = uicontrol('Style','edit','Position',[w-380, h-220, 90, 30],'String','Not Set','BackgroundColor',[.6,.2,.2]);
Ouptext = uicontrol('Style','pushbutton','Position',[w-250, h-180, 90, 30],'String','Output File Name:','Callback',@Oupfn);
Ouptexte = uicontrol('Style','edit','Position',[w-250, h-220, 90, 30],'String','Not Set','BackgroundColor',[.6,.2,.2]); %'Callback',@callbackfn);
Ardtext = uicontrol('Style','edit','Position',[w-120, h-220, 90, 30],'String','Not Connected','BackgroundColor',[.6,.2,.2]);
Conbut = uicontrol('Style','pushbutton','Position',[w-120, h-180, 90, 30],'String','Connect Arduino', ...
    'Callback',@Conbutfn);
stexp = uicontrol('Style','pushbutton','Position',[w-275, h-100, 150, 60],'String','Start Experiment', ...
    'Callback',@stexpfn);

stexp1 = uicontrol('Style','text','Position',[w-300, h-175, 200, 120],'String','Starting Experiment','Visible','off');
stexp2 = uicontrol('Style','text','Position',[w-300, h-175, 200, 120],'String','Transfering PSD','Visible','off');
stexp3 = uicontrol('Style','text','Position',[w-300, h-175, 200, 120],'String','Collecting Data','Visible','off');
stexp4 = uicontrol('Style','text','Position',[w-300, h-175, 200, 120],'String','Finished!','Visible','off');
set([stexp1,stexp2,stexp3,stexp4],'BackgroundColor',[.8,.8,.8],'Fontsize',30)

Trybut = uicontrol('Style','pushbutton','Position',[w-120, h-220, 90, 30],'String','New Experiment', ...
    'Callback',@Tryfn,'Visible','off');
%align([InpF, Inptext,Ouptext,Ouptexte,Ardtext,Conbut,stexp],'Center','Center')

    function InpFfn(source,eventdata)
        [stg,afs] = uigetfile();
        if stg(end) ~= 't'
            errordlg('Not a proper file format','File Error')
            stg = []; afs = [];
        else
            set(Inptext, 'String', stg)
            set(Inptext, 'BackgroundColor', 'Green')
        end
    end

    function Conbutfn(source,eventdata)
        coma = inputdlg('Please type in the COM port which the Arduino is connected to (eg. COM3)');
        sinfo = instrhwinfo('serial');
        comcck = 0;
        if isempty(coma) ~= 1
            for i = 1:length(sinfo.AvailableSerialPorts)
                if strcmp(sinfo.AvailableSerialPorts(i),coma)
                    comcck = 1;
                    set(Ardtext, 'String', coma)
                    set(Ardtext, 'BackgroundColor', 'Green')
                end
            end
            if comcck == 0
                errordlg('Arduino not connected','COM PORT Error')
                coma = [];
            end
        end
        
    end

    function Oupfn(source,eventdata)
        nma = inputdlg('Please enter desired output filename (eg. TESTDATA)');
        if isempty(nma) ~= 1
            flist = dir;
            ccheck = 0;
            for i = 1:length(flist)
                if strcmp(flist(i).name, nma{1})
                    ccheck = 1;
                end
            end
            if ccheck == 1;
                errordlg('File already exsists, enter new name','File Error')
                nma = [];
            else
                set(Ouptexte, 'String', nma)
                set(Ouptexte, 'BackgroundColor', 'Green')
            end
        end
        
    end

    function stexpfn(source,eventdata)
        st1 = get(Ouptexte,'String');
        st2 = get(Ardtext, 'String');
        if isempty(st1) == 0 && isempty(st2)==0 && isempty(stg) ==0 && isempty(coma) == 0
            set([InpF, Inptext,Ouptext,Ouptexte,Ardtext,Conbut,stexp],'Visible','off')
            set(stexp1, 'Visible','on')
            oldSerial = instrfind('Port', coma);  % Check to see if there are existing serial objects (instrfind) whos 'Port' property is set to 'COM1'
            % can also use instrfind() with no input arguments to find ALL existing serial objects
            if (~isempty(oldSerial))  % if the set of such objects is not(~) empty
                delete(oldSerial)
            end
            
            s1 = serial(nma);    % define serial port
            s1.BaudRate=115200;               % define baud rate
            set(s1, 'terminator', 'LF');    % define the terminator for println
            fopen(s1);
            
            
            a = 'b';
            while (a~= 'a')
                a = fread(s1,1,'uchar');
            end
            
            set(stexp1, 'Visible','off')
            set(stexp2, 'Visible','on')
            PSD = load(nma);
            [mm,nn] = size(PSD);
            fprintf(s1,'%d',mm);
            fprintf(s1,'%d',nn);
            for ii = 1:mm
                for jj = 1:nn
                    fprintf(s1,'%d',PSD(mm,nn));
                end
            end
            
            
            
            set(stexp2, 'Visible','off')
            
            set(stexp3, 'Visible','on')
            a = 'b';
            while (a~= 'a')
                a = fread(s1,1,'uchar');
            end
            set(stexp3, 'Visible','off')
            if (a=='a')
                disp('serial read')
            end
            m = 1; c = 1;
            while(a~='c')
                if(s1.BytesAvailable ~= 0)
                    kp{m,c} = fscanf(s1,'%u');
                    if kp{m,c} == 1
                        m = m + 1;
                        c = 0;
                    elseif kp{m,c} == 2
                        a = 'c';
                    end
                    c =c +1;
                end
            end
            
            set(stexp4, 'Visible','on')
            set(Trybut,'Visible','on')
            
            
        else
            errordlg('Please check to make sure all boxes are green')
        end
        
    end
    function Tryfn(source,eventdata)
        set([stexp4,Trybut], 'Visible','off')
        InpF = uicontrol('Style','pushbutton','Position',[w-380, h-180, 90, 30],'String','Select File Input', ...
            'Callback',@InpFfn);
        Inptext = uicontrol('Style','edit','Position',[w-380, h-220, 90, 30],'String','Not Set','BackgroundColor',[.6,.2,.2]);
        Ouptext = uicontrol('Style','pushbutton','Position',[w-250, h-180, 90, 30],'String','Ouput File Name:','Callback',@Oupfn);
        Ouptexte = uicontrol('Style','edit','Position',[w-250, h-220, 90, 30],'String','Not Set','BackgroundColor',[.6,.2,.2]); %'Callback',@callbackfn);
        Ardtext = uicontrol('Style','edit','Position',[w-120, h-220, 90, 30],'String','Not Connected','BackgroundColor',[.6,.2,.2]);
        Conbut = uicontrol('Style','pushbutton','Position',[w-120, h-180, 90, 30],'String','Connect Arduino', ...
            'Callback',@Conbutfn);
        stexp = uicontrol('Style','pushbutton','Position',[w-275, h-100, 150, 60],'String','Start Experiment', ...
            'Callback',@stexpfn);
    end

end