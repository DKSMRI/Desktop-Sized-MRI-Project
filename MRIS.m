function MRIS
h = 250;
w = 400;
global stg afs
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
        set(Inptext, 'String', stg)
        set(Inptext, 'BackgroundColor', 'Green')
    end

    function Conbutfn(source,eventdata)
        a = inputdlg('Please type in the COM port which the Arduino is connected to (eg. COM3)');
        if isempty(a) ~= 1
            set(Ardtext, 'String', a)
            set(Ardtext, 'BackgroundColor', 'Green')
        end
        
    end

    function Oupfn(source,eventdata)
        a = inputdlg('Please enter desired output filename (eg. TESTDATA)');
        if isempty(a) ~= 1
            set(Ouptexte, 'String', a)
            set(Ouptexte, 'BackgroundColor', 'Green')
        end
        
    end

    function stexpfn(source,eventdata)
        st1 = get(Ouptexte,'String');
        st2 = get(Ardtext, 'String');
        if isempty(st1) == 0 && isempty(st2)==0 && isempty(stg) ==0
            set([InpF, Inptext,Ouptext,Ouptexte,Ardtext,Conbut,stexp],'Visible','off')
            set(stexp1, 'Visible','on')
            pause(2)
            set(stexp1, 'Visible','off')
            set(stexp2, 'Visible','on')
            pause(2)
            set(stexp2, 'Visible','off')
            
            set(stexp3, 'Visible','on')
            pause(2)
            set(stexp3, 'Visible','off')
            
            set(stexp4, 'Visible','on')
            set(Trybut,'Visible','on')
            pause(2)
            
            
            
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