function varargout = simpleTrackBuilder(varargin) 

% SIMPLETRACKBUILDER MATLAB code for simpleTrackBuilder.fig
%      SIMPLETRACKBUILDER, by itself, creates a new SIMPLETRACKBUILDER or raises the existing
%    singleton*.
%
%      H = SIMPLETRACKBUILDER returns the handle to a new SIMPLETRACKBUILDER or the handle to
%      the existing singleton*.
%
%      SIMPLETRACKBUILDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMPLETRACKBUILDER.M with the given input arguments.
%
%      SIMPLETRACKBUILDER('Property','Value',...) creates a new SIMPLETRACKBUILDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simpleTrackBuilder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simpleTrackBuilder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simpleTrackBuilder

% Last Modified by GUIDE v2.5 03-Nov-2015 11:34:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simpleTrackBuilder_OpeningFcn, ... 
                   'gui_OutputFcn',  @simpleTrackBuilder_OutputFcn, ... 
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before simpleTrackBuilder is made visible.
function simpleTrackBuilder_OpeningFcn(hObject, ~, handles, varargin)%MODIFIED
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simpleTrackBuilder (see VARARGIN)
    
    % Add root to path if not added yet
    handles = addDirectories2Path(handles);

    handles.sysName = 'new_track';

    handles.STRAIGHT_PIECE = 'straight';
    handles.CURVED_PIECE = 'curved';
    handles.CHICANE_PIECE = 'chicane';
    
    set(handles.rotate_pshBtn, 'visible', 'off');% ADDED NO NEED IF THERE IS NO ROTATE BUTTON
        
    handles.dir_UP = 0;
    handles.dir_DOWN = 1;
    handles.dir_LEFT = 2;
    handles.dir_RIGHT = 3;
    
    handles.strPieceCnt = 0; 
    handles.curPieceCnt = 0; 
    handles.chiPieceCnt = 0; 
        
    handles.pieceNumber = 0; 
    handles.previousPieceType = 0; 
    handles.previousPieceRef = [];
        
    handles.lib_worldFrame = 'sm_lib/Frames and Transforms/World Frame';
    handles.lib_rigidTransform = 'sm_lib/Frames and Transforms/Rigid Transform';
    handles.lib_solvConf = 'nesl_utility/Solver Configuration';

    handles.lib_straightPiece = 'simulatorLibrary/Straight Track Piece';
    handles.lib_curvedPiece = 'simulatorLibrary/Curved Track Piece';
    handles.lib_chicanePiece = 'simulatorLibrary/Chicane Track Piece';

    handles.selectedPiece = handles.STRAIGHT_PIECE;
    handles.currentPos = [0 0 0];
    handles.direction = handles.dir_UP;
    handles.rotationAngle = 0;

    handles.firstPiece = true;

    new_system(handles.sysName);
    load_system(handles.sysName);

    handles.x = 30;
    handles.y = 30;
    handles.w = 60;
    handles.h = 60;

    handles.offset = 40;

    handles.posYShift = [0 handles.h+handles.offset 0 handles.h+handles.offset];

    handles.sourcePos = [handles.x handles.y handles.x+handles.w handles.y+handles.h];
    handles.transformPos = [150 handles.y 150+handles.w handles.y+handles.h];
    handles.piecePos = [270 handles.y 270+handles.w handles.y+handles.h];

    add_block(handles.lib_worldFrame, [handles.sysName '/World Frame'], 'Position', handles.sourcePos);

    hdl_worldFrame = get_param([handles.sysName '/World Frame'], 'handle');
    set_param(hdl_worldFrame, 'Orientation', 'right');

    handles.sourcePos = handles.sourcePos + handles.posYShift;

    add_block(handles.lib_solvConf, [handles.sysName '/Solver Configuration'], 'Position', handles.sourcePos);
    add_line(handles.sysName, 'World Frame/RConn1', 'Solver Configuration/RConn1', 'autorouting', 'on');

    handles.sourcePos = handles.sourcePos + handles.posYShift; %??????
        
    if handles.pieceNumber == 0
        set(handles.undo_pshBtn, 'visible', 'off');
        set(handles.changeDir_pshBtn, 'visible', 'off');
    end
        
    % Initialise VR     
    vr_file = fopen('track.wrl','w');
    fprintf(vr_file, '#VRML V2.0 utf8\n');
    handles.vr_file = vr_file;
    handles.vr_track = {};
    
    path2base = which('base_world.wrl');

    handles.vr_world = vrworld(path2base, 'new');
    open(handles.vr_world);
    
    % Add externproto for straight piece & curve pieces
    path2straight = which('proto_straight.wrl');
    path2curve = which('proto_curve.wrl');
    path2chicane = which('proto_chicane.wrl');

    % create an EXTERNPROTO with specified marker
    try
      addexternproto(handles.vr_world, path2straight, 'StraightTrackPiece');      
      addexternproto(handles.vr_world, path2curve, 'CurvedTrackPiece');
      addexternproto(handles.vr_world, path2chicane, 'ChicaneTrackPiece');
    catch ME
      % if required PROTO is already contained don't throw an exception
      if ~strcmpi(ME.identifier, 'VR:protoexists')
        throwAsCaller(ME);
      end
    end
    
    fig_hdl = gcf;
    
    overall_view = vrnode(handles.vr_world, 'Overall_View','Viewpoint');
    overall_view.position = [-5 5 20];
    
    vrcanvas = vr.canvas(handles.vr_world, fig_hdl, [20 30 350 350]);
    set(vrcanvas,'Units','normalized')
    vrcanvas.Viewpoint = 'Overall_View';

    % add map for convenience
    piece_map = containers.Map;
    piece_map(handles.STRAIGHT_PIECE) = 'StraightTrackPiece';
    piece_map(handles.CURVED_PIECE) = 'CurvedTrackPiece';
    piece_map(handles.CHICANE_PIECE) = 'ChicaneTrackPiece';
    handles.piece_map = piece_map;    
    handles.trackCtr = 0;

    % add shadow piece
    handles.shadowPiece = addShadowPiece(handles);
    
    % Choose default command line output for simpleTrackBuilder
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes simpleTrackBuilder wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = simpleTrackBuilder_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in saveTrack_pshBtn.
function saveTrack_pshBtn_Callback(hObject, ~, handles)
% hObject    handle to saveTrack_pshBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    open_system(handles.sysName);
    
%     save_system(handles.sysName, strcat('../vrIntegration/tracks/',handles.sysName)); % IT WAS LOOKIN FOR     vrIntegration//vrIntegration/tracks/
%     save(handles.vr_world,strcat('../vrIntegration/tracks/',handles.sysName,'.wrl'));  % IT WAS LOOKIN FOR     vrIntegration//vrIntegration/tracks/
%     overall_view = vrnode(handles.vr_world, 'Overall_View');
%     delete(overall_view);
    camera = vrnode(handles.vr_world, 'Camera', 'Viewpoint');
    camera.jump = 'TRUE';
    camera.fieldOfView = 0.785398;
    camera.orientation = [-1 0 0  1.5708];
    camera.position = [0 6 1];
    camera.description = 'Camera_View';
    
    saveName = inputdlg('Enter file name:', 'Track File Name');
    saveName = saveName{1};
    
    tracksDirectory = [handles.path_VR, handles.sep, 'tracks'];
    filepathWithoutExtension = [tracksDirectory, handles.sep, saveName];
    
    save_system(handles.sysName, [ filepathWithoutExtension,'.slx']);
    save(handles.vr_world, [ filepathWithoutExtension,'.wrl']);
    
    delete(camera);
    
    handles.sysName = saveName;
    
    load_system(handles.sysName);
    
    guidata(hObject, handles);
    

% --- Executes when uibuttongroup1 is resized.
function uibuttongroup1_SizeChangedFcn(~, ~, ~)
% hObject    handle to uibuttongroup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function angle = getNewRotationAngle(handles)
    switch handles.direction
        case handles.dir_UP
            angle = 0;
        case handles.dir_LEFT
            angle = 90;
        case handles.dir_DOWN
            angle = 180;
        case handles.dir_RIGHT
            angle = 270;
    end

function applyTransform(transformHandle, x, y, z, angle)
    ignoredTranslationParams = '|0|m|0|m|0|deg';
    cartesianParam = sprintf('|Cartesian|ft|+Z|0|[%s %s %s]', num2str(x), num2str(y), num2str(z));
    translateString = strcat(cartesianParam, ignoredTranslationParams);

    ignoredRotationParams = '|[0 0 1]|+X|+Y|+Y|+Z|FollowerAxes|XYX|[0 0 0]|deg|[1 0 0; 0 1 0; 0 0 1]';
    rotationParam = sprintf('|StandardAxis|deg|+Z|%s',num2str(angle));
    rotationString = strcat(rotationParam, ignoredRotationParams);
        
    transformString = sprintf('RigidTransform%s%s|simmechanics.library.frames_transforms.rigid_transform', translateString, rotationString);
    
    set_param(transformHandle, 'MaskValueString', transformString);

function [x, y, z, deg, theta] = getCurrentState(handles)
    x = handles.currentPos(1);
    y = handles.currentPos(2);
    z = handles.currentPos(3);
    deg = handles.rotationAngle;    
    theta = deg * pi / 180; 

% add vr node and return the name of the piece
function vrName=addNode2VR(handles, piece, pos, theta) 
    vrName = sprintf('%s_%d', piece, handles.trackCtr);
    vrPiece = vrnode(handles.vr_world, vrName, piece);
    vrPiece.trackTranslation = [pos(1) pos(3) -pos(2)]; % flip y and z for vr, 
    vrPiece.trackRotation = [0 1 0 theta]; 
    handles.trackCtr = handles.trackCtr + 1; % fix this

function deleteNodeFromVR(handles, vrName)
    myNode = vrnode(handles.vr_world, vrName);
    delete(myNode);
    dummyPiece = vrnode(handles.vr_world, 'DummyPiece', 'StraightTrackPiece'); %hacky move to refresh picture in GUI after applying UNDO BUTTON 
    delete(dummyPiece); %hacky move to refresh picture in GUI after applying UNDO BUTTON
    
function vrName=addShadowPiece(handles)
    [x, y, z, rotationAngle, ~] = getCurrentState(handles);
    [~, ~, renderPos] = getNextState(handles, rotationAngle);
    
    rad = rotationAngle * pi / 180;
    vrName = addNode2VR(handles, handles.piece_map(handles.selectedPiece), renderPos, rad);    
    % change the opacity of the shadow piece
    shadowPiece = vrnode(handles.vr_world, vrName);
    transparency = 0.7;
    if sum(abs([x y z])) == 0 && handles.trackCtr > 0
        transparency = 1;
    end
        
    shadowPiece.trackTransparency = transparency;

function deleteShadowPiece(handles)
    deleteNodeFromVR(handles, handles.shadowPiece);
    handles.shadowPiece = '';
    
% Get next position and direction as well as rendering position Mechanics&VR
function [nextPos, direction, renderPos] = getNextState(handles, angle)
    piece = handles.selectedPiece;
    x = handles.currentPos(1);
    y = handles.currentPos(2);
    z = handles.currentPos(3);
    xPosShift = 0;
    yPosShift = 0;
    zPosShift = 0;    
    xShift = 0;
    yShift = 0;
    zShift = 0;    
    direction = handles.direction;

    if strcmp(piece, handles.CURVED_PIECE)
        switch direction
            case handles.dir_UP
                if angle == 0
                    xShift = -2;
                    direction = handles.dir_LEFT;
                else
                    xShift = 2;
                    direction = handles.dir_RIGHT;
                end
                xPosShift = xShift;
                yPosShift = 2;
            case handles.dir_LEFT
                if angle == 90
                    yShift = -2;
                    direction = handles.dir_DOWN;
                else
                    yShift = 2;
                    direction = handles.dir_UP;
                end
                xPosShift = -2;
                yPosShift = yShift;
            case handles.dir_DOWN
                if angle == 180
                    xShift = 2;
                    direction = handles.dir_RIGHT;
                else
                    xShift = -2;
                    direction = handles.dir_LEFT;
                end
                xPosShift = xShift;
                yPosShift = -2;
            case handles.dir_RIGHT
                if angle == 270
                    yShift = 2;
                    direction = handles.dir_UP;
                else
                    yShift = -2;
                    direction = handles.dir_DOWN;
                end
                xPosShift = 2;
                yPosShift = yShift;
        end
        
    else % for straight and chicane
         switch direction
            case handles.dir_UP
                yShift = 2;
                yPosShift = 4;
            case handles.dir_LEFT
                xShift = -2;
                xPosShift = -4;
            case handles.dir_DOWN
                yShift = -2;
                yPosShift = -4;
            case handles.dir_RIGHT
                xShift = 2;
                xPosShift = 4;
         end
    end
    nextPos = [x + xPosShift, y + yPosShift, z + zPosShift];
    renderPos = [x + xShift, y + yShift, z + zShift];
    
    
% --- Executes on button press in add_pshBtn.
function add_pshBtn_Callback(hObject, ~, handles)
% hObject    handle to add_pshBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [x, y, z, rotationAngle, rotationRadian] = getCurrentState(handles);
        
    if strcmp(handles.selectedPiece, handles.STRAIGHT_PIECE)
        newPiece_libRef = handles.lib_straightPiece;
        
        handles.strPieceCnt = handles.strPieceCnt + 1;        
        handles.newPieceName = strcat('strPiece', num2str(handles.strPieceCnt));
        handles.newPieceTransform = strcat(handles.newPieceName, 'Transform');
        
        handles.pieceNumber = handles.pieceNumber + 1;
        handles.previousPieceType = 1;
        
        handles.previousPieceRef = [handles.previousPieceRef ; handles.previousPieceType handles.strPieceCnt handles.currentPos handles.direction handles.rotationAngle];
        
        switch handles.direction
            case handles.dir_UP
                y = y + 2;
                handles.currentPos(2) = handles.currentPos(2) + 4;
            case handles.dir_LEFT
                x = x-2;
                handles.currentPos(1) = handles.currentPos(1) - 4;
            case handles.dir_DOWN
                y = y - 2;
                handles.currentPos(2) = handles.currentPos(2) - 4;
            case handles.dir_RIGHT
                x = x + 2;
                handles.currentPos(1) = handles.currentPos(1) + 4;
        end

        if handles.pieceNumber ~= 0
                set(handles.undo_pshBtn, 'visible', 'on');
                set(handles.changeDir_pshBtn, 'visible', 'off');
                set(handles.rotate_pshBtn, 'visible', 'off');
         
        end  

    elseif   strcmp(handles.selectedPiece, handles.CHICANE_PIECE)
        newPiece_libRef = handles.lib_chicanePiece;
        
        handles.chiPieceCnt = handles.chiPieceCnt + 1;
        handles.newPieceName = strcat('chiPiece', num2str(handles.chiPieceCnt));
        handles.newPieceTransform = strcat(handles.newPieceName, 'Transform');
        
        handles.pieceNumber = handles.pieceNumber + 1;
        handles.previousPieceType = 2;
       
        handles.previousPieceRef = [handles.previousPieceRef ; handles.previousPieceType handles.chiPieceCnt handles.currentPos handles.direction handles.rotationAngle];
        
        switch handles.direction
            case handles.dir_UP
                y = y + 2;
                handles.currentPos(2) = handles.currentPos(2) + 4;
            case handles.dir_LEFT
                x = x-2;
                handles.currentPos(1) = handles.currentPos(1) - 4;
            case handles.dir_DOWN
                y = y - 2;
                handles.currentPos(2) = handles.currentPos(2) - 4;
            case handles.dir_RIGHT
                x = x + 2;
                handles.currentPos(1) = handles.currentPos(1) + 4;
        end
        
        if handles.pieceNumber ~= 0
                set(handles.undo_pshBtn, 'visible', 'on');
                set(handles.changeDir_pshBtn, 'visible', 'off');
                set(handles.rotate_pshBtn, 'visible', 'off');
         
        end
        
    else
        newPiece_libRef = handles.lib_curvedPiece;
        
        handles.curPieceCnt = handles.curPieceCnt + 1;
        handles.newPieceName = strcat('curPiece', num2str(handles.curPieceCnt));
        handles.newPieceTransform = strcat(handles.newPieceName, 'Transform');
        
        handles.pieceNumber = handles.pieceNumber + 1;
        handles.previousPieceType = 3;
        
        handles.previousPieceRef = [handles.previousPieceRef ; handles.previousPieceType handles.curPieceCnt handles.currentPos handles.direction handles.rotationAngle];
       
        xShift = 0;
        yShift = 0;
        switch handles.direction
            case handles.dir_UP
                if rotationAngle == 0
                    xShift = -2;
                    handles.direction = handles.dir_LEFT;
                else
                    xShift = 2;
                    handles.direction = handles.dir_RIGHT;
                end
                posXShift = xShift;
                posYShift = 2;
            case handles.dir_LEFT
                if rotationAngle == 90
                    yShift = -2;
                    handles.direction = handles.dir_DOWN;
                else
                    yShift = 2;
                    handles.direction = handles.dir_UP;
                end
                posXShift = -2;
                posYShift = yShift;
            case handles.dir_DOWN
                if rotationAngle == 180
                    xShift = 2;
                    handles.direction = handles.dir_RIGHT;
                else
                    xShift = -2;
                    handles.direction = handles.dir_LEFT;
                end
                posXShift = xShift;
                posYShift = -2;
            case handles.dir_RIGHT
                if rotationAngle == 270
                    yShift = 2;
                    handles.direction = handles.dir_UP;
                else
                    yShift = -2;
                    handles.direction = handles.dir_DOWN;
                end
                posXShift = 2;
                posYShift = yShift;
                                
        end
        
        x = x + xShift;
        y = y + yShift;
        handles.currentPos(1) = handles.currentPos(1) + posXShift;
        handles.currentPos(2) = handles.currentPos(2) + posYShift;
        
    end
      
    % VR canvas update
    deleteShadowPiece(handles)
    addNode2VR(handles, handles.piece_map(handles.selectedPiece), [x y z], rotationRadian) 
    handles.trackCtr = handles.trackCtr + 1;
    
    strcat(handles.sysName,'/',handles.newPieceName)
    
    newPiece_libRef
    strcat(handles.sysName,'/',handles.newPieceName)
    handles.piecePos
    
    add_block(newPiece_libRef, strcat(handles.sysName,'/',handles.newPieceName), 'Position', handles.piecePos);
    
    
    
    add_block(handles.lib_rigidTransform, strcat(handles.sysName,'/',handles.newPieceTransform), 'Position', handles.transformPos);
    add_line(handles.sysName, 'World Frame/RConn1', strcat(handles.newPieceTransform, '/LConn1'), 'autorouting', 'on');
    add_line(handles.sysName, strcat(handles.newPieceTransform,'/RConn1'), strcat(handles.newPieceName,'/LConn1'));

    hdl_transform = get_param( strcat(handles.sysName,'/', handles.newPieceTransform), 'handle');

    applyTransform(hdl_transform, x, y, z, rotationAngle);

    handles.piecePos = handles.piecePos + handles.posYShift;
    handles.transformPos = handles.transformPos + handles.posYShift;
    handles.rotationAngle = getNewRotationAngle(handles);
    
    if handles.pieceNumber ~= 0
                set(handles.undo_pshBtn, 'visible', 'on');
    end
    
    handles.shadowPiece = addShadowPiece(handles);
    vrdrawnow;
    
%  Another implemetiotion of appearing push Buttons

%     if handles.firstPiece
%         handles.firstPiece = false;
%         set(handles.rotate_pshBtn, 'visible', 'off');
%     end

    guidata(hObject, handles);
    
    % --- Executes on button press in rotate_pshBtn.
function undo_pshBtn_Callback(hObject, ~, handles)
% hObject    handle to undo_pshBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NO NEED IN DELETING CONNECTION LINES, especially IF WE PUT BLOCKS AT THE SAME POSITION

vrName = '';
if handles.previousPieceRef(handles.pieceNumber,1)== 1
           
        handles.strPieceCnt = handles.previousPieceRef(handles.pieceNumber,2);           
        handles.newPieceName = strcat('strPiece', num2str(handles.strPieceCnt)); 
        handles.newPieceTransform = strcat(handles.newPieceName, 'Transform');
        delete_block([handles.sysName strcat('/',handles.newPieceName)]);
        delete_block([handles.sysName strcat('/',handles.newPieceTransform)]);
        handles.strPieceCnt = handles.strPieceCnt - 1;
        vrName = 'StraightTrackPiece';
  
    elseif handles.previousPieceRef(handles.pieceNumber,1)== 2
          
        handles.chiPieceCnt = handles.previousPieceRef(handles.pieceNumber,2);        
        handles.newPieceName = strcat('chiPiece', num2str(handles.chiPieceCnt));
        handles.newPieceTransform = strcat(handles.newPieceName, 'Transform');
        delete_block([handles.sysName strcat('/',handles.newPieceName)]);
        delete_block([handles.sysName strcat('/',handles.newPieceTransform)]);
        handles.chiPieceCnt = handles.chiPieceCnt - 1;
        vrName = 'ChicaneTrackPiece';
     
    elseif handles.previousPieceRef(handles.pieceNumber,1)== 3
    
        handles.curPieceCnt = handles.previousPieceRef(handles.pieceNumber,2);        
        handles.newPieceName = strcat('curPiece', num2str(handles.curPieceCnt));
        handles.newPieceTransform = strcat(handles.newPieceName, 'Transform');
        delete_block([handles.sysName strcat('/',handles.newPieceName)]);
        delete_block([handles.sysName strcat('/',handles.newPieceTransform)]);
        handles.curPieceCnt = handles.curPieceCnt - 1;
        vrName = 'CurvedTrackPiece';
         
end

handles.trackCtr = handles.trackCtr - 1;
% vrName = sprintf('%s_%d', vrName, handles.trackCtr)
% deleteNodefromVR(handles, vrName);
myNode = vrnode(handles.vr_world, sprintf('%s_%d', vrName, handles.trackCtr));
delete(myNode);

handles.currentPos = handles.previousPieceRef(handles.pieceNumber,3:5);
handles.direction = handles.previousPieceRef(handles.pieceNumber,6);
handles.rotationAngle = handles.previousPieceRef(handles.pieceNumber,7); 

handles.previousPieceRef(handles.pieceNumber,:)=[];
handles.pieceNumber = handles.pieceNumber - 1;

    if handles.pieceNumber == 0
        set(handles.undo_pshBtn, 'visible', 'off');
    end   

deleteShadowPiece(handles)
handles.shadowPiece = addShadowPiece(handles);
vrdrawnow;

% dummyPiece = vrnode(handles.vr_world, 'DummyPiece', 'StraightTrackPiece'); %hacky move to refresh picture in GUI after applying UNDO BUTTON 
% delete(dummyPiece); %hacky move to refresh picture in GUI after applying UNDO BUTTON

vrdrawnow;

%END    
    guidata(hObject, handles);

    
    %COMMENT rotate push button OUT!!!!! OR MAKE IT INVISIBLE OR DELETE IT IF ITS NOT IN USE  
    %COMMENT rotate push button OUT!!!!!    
    %COMMENT rotate push button OUT!!!!!
    
% --- Executes on button press in rotate_pshBtn.
function rotate_pshBtn_Callback(hObject, ~, handles)
% hObject    handle to rotate_pshBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    switch handles.direction
        case handles.dir_UP
            handles.direction = handles.dir_LEFT;
            handles.rotationAngle = 90;
        case handles.dir_LEFT
            handles.direction = handles.dir_DOWN;
            handles.rotationAngle = 180;
        case handles.dir_DOWN
            handles.direction = handles.dir_RIGHT;
            handles.rotationAngle = 270;
        case handles.dir_RIGHT
            handles.direction = handles.dir_UP;
            handles.rotationAngle = 0;
    end
    
    guidata(hObject, handles);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 % gracefully close the VR
    close(handles.vr_world)
    close_system(handles.sysName, 0);
    % Hint: delete(hObject) closes the figure
    delete(hObject);


% --- Executes on button press in straightPiece_rBtn.
function straightPiece_rBtn_Callback(hObject, ~, handles)
% hObject    handle to straightPiece_rBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.rotationAngle = getNewRotationAngle(handles);
    handles.selectedPiece = handles.STRAIGHT_PIECE;
    
    set(handles.changeDir_pshBtn, 'visible', 'off');
    
    deleteShadowPiece(handles)
    handles.shadowPiece = addShadowPiece(handles);
    vrdrawnow;

    guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of straightPiece_rBtn


% --- Executes on button press in curved_rBtn.
function curved_rBtn_Callback(hObject, ~, handles)
% hObject    handle to curved_rBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.rotationAngle = getNewRotationAngle(handles); %may be this was missing ????????????
    handles.selectedPiece = handles.CURVED_PIECE;    
    
    set(handles.changeDir_pshBtn, 'visible', 'on');   
    
    deleteShadowPiece(handles)
    handles.shadowPiece = addShadowPiece(handles);
    vrdrawnow;

    
    guidata(hObject, handles);

    % Hint: get(hObject,'Value') returns toggle state of curved_rBtn

    
    % --- Executes on button press in curved_rBtn.
function chicane_rBtn_Callback(hObject, ~, handles)
% hObject    handle to chicane_rBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.rotationAngle = getNewRotationAngle(handles); 
    handles.selectedPiece = handles.CHICANE_PIECE;

    set(handles.changeDir_pshBtn, 'visible', 'off');  
        
    deleteShadowPiece(handles)
    handles.shadowPiece = addShadowPiece(handles);
    vrdrawnow;

    
    guidata(hObject, handles);

    % Hint: get(hObject,'Value') returns toggle state of chicane_rBtn

    
% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in changeDir_pshBtn.
function changeDir_pshBtn_Callback(hObject, ~, handles)
% hObject    handle to changeDir_pshBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    switch handles.direction
        case handles.dir_UP
            handles.rotationAngle = mod(handles.rotationAngle+90, 180);
        case handles.dir_LEFT
            handles.rotationAngle = mod(handles.rotationAngle, 180) + 90;
        case handles.dir_DOWN
            handles.rotationAngle = mod(handles.rotationAngle-90, 180) + 180;
        case handles.dir_RIGHT
            handles.rotationAngle = mod(mod(handles.rotationAngle, 180)-90, 360);
    end
    
    deleteShadowPiece(handles)
    handles.shadowPiece = addShadowPiece(handles);
    vrdrawnow;
    
    guidata(hObject, handles);


    
% --- Executes on button press in run_pshBtn.
function run_pshBtn_Callback(~, ~, handles)
% hObject    handle to run_pshBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    sim(handles.sysName);
    
    % --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Helper%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [handles] = addDirectories2Path(handles)
% Adds required directories to path, probably this is a bad idea?
    handles.ROOT_DIR = 'simulation-hipeds';
    handles.SIMULINK_LIBRARY = 'library';
    handles.TRACK_GENERATOR = 'trackGenerator'; 
    handles.VR = 'vrIntegration';
    handles.GROUP_1 = 'Group 1';
    
    current_path = pwd();
    if ispc
       handles.sep = '\'; 
    else 
       handles.sep = '/';
    end
    dirs = strsplit(current_path, handles.sep);
    % build path to root    
    ROOT_PATH = '';
    for i = 1:length(dirs)
        cur_dir = dirs(i);
        ROOT_PATH = strcat(ROOT_PATH, cur_dir);
        if strcmp(cur_dir, handles.ROOT_DIR)            
            break; 
        else
            ROOT_PATH = strcat(ROOT_PATH, handles.sep);
        end
    end
    handles.ROOT_PATH = ROOT_PATH{1};
    
    if handles.ROOT_PATH(1) == '\'
        handles.ROOT_PATH = ['\', handles.ROOT_PATH];
    end
    
    if exist(handles.ROOT_PATH) == 7 % meaning folder exists
        addpath(handles.ROOT_PATH);
        addpath([handles.ROOT_PATH, handles.sep, handles.SIMULINK_LIBRARY]);
        addpath([handles.ROOT_PATH, handles.sep, handles.TRACK_GENERATOR]);        
        addpath([handles.ROOT_PATH, handles.sep, handles.VR]);
        addpath([handles.ROOT_PATH, handles.sep, handles.GROUP_1]);
    end
    
    handles.path_ROOT_DIR = handles.ROOT_PATH;
    handles.path_SIMULINK_LIBRARY = [handles.ROOT_PATH, handles.sep, handles.SIMULINK_LIBRARY];
    handles.path_TRACK_GENERATOR = [handles.ROOT_PATH, handles.sep, handles.TRACK_GENERATOR];
    handles.path_VR = [handles.ROOT_PATH, handles.sep, handles.VR];
    handles.path_GROUP_1 = [handles.ROOT_PATH, handles.sep, handles.GROUP_1];
    
    

