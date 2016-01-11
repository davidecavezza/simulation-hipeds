% Free memory and prevent corruption
clear all;

%Parameters for the simulation
t = 0: 0.02*pi : 4*pi;
a = 0.5; b = 1;

% Create a vrworld object and open it
world = vrworld('curve_pretty.wrl', 'new');
open(world);

% Create the vrnode objects so that you can modify the properties within
% MATLAB
curveTrackPiece= vrnode(world, 'CurveTrackPiece');

% Create the MATLAB GUI
% Create a figure and determine its size and location width:880 pixels,
% height: 400 pixels
figure_height=400;
view_width=350;
corner_x=20;
corner_y=10;
clearance=20;
figref = figure('Position',[100 450 3*view_width+4*clearance figure_height+clearance])

% Create the MATLAB GUI with two views of the aircraft
% First create the vrcanvas object for the first view. Specify the location
% and size of the view in pixels
c1 = vr.canvas(world, gcf, [corner_x corner_y view_width figure_height]);
% Normalize to allow scaling of the view when the figure window is resized.
set(c1,'Units','normalized')
c1.Viewpoint = 'Overall_View';


% get the path to the wrl file with marker PROTOs
pathtomarkers = which('vr_markers.wrl');
% use the tetrahedron shape
MarkerName = 'Marker_Sphere';
% create an EXTERNPROTO with specified marker
try
  addexternproto(world, pathtomarkers, MarkerName);
catch ME
  % if required PROTO is already contained don't throw an exception
  if ~strcmpi(ME.identifier, 'VR:protoexists')
    throwAsCaller(ME);
  end
end



for i=1:length(t)
    % use pause to control the speed of the simulation
    pause(0.02);
    vector_1=[a*cos(t(i)) b*t(i) a*sin(t(i))];
    vector_2=[-a*sin(t(i))  b    a*cos(t(i))];
    dcm_component_x=-[-a*cos(t(i)) 0 -a*sin(t(i))];
    dcm_component_x=dcm_component_x/sqrt(dot(dcm_component_x,dcm_component_x));
    dcm_component_z=vector_2/sqrt(dot(vector_2,vector_2));
    dcm_component_y=cross(dcm_component_z,dcm_component_x);
    dcm=[dcm_component_x' dcm_component_y' dcm_component_z'];
    quat=dcm2quat(dcm);
    quat=quatnormalize(quat);
    theta= 2*acos(quat(1,1));
    
    if theta ~=0
        vector=[quat(1,2)  quat(1,3) quat(1,4)]/sin(theta/2);
    else
        vector=[0 0 0];
    end
    
    %vector_cross(i,:)=cross(vector_2, vector_3);
    %angle_cosine(i)=acos(dot(vector_2, vector_3)/(norm(vector_2)*norm(vector_3)));
    curveTrackPiece.translation=[0 10 10]+vector_1;
    curveTrackPiece.rotation=[vector -theta];
    spotlight.direction=0.1*vector;
    
    newMarker = vrnode(world, sprintf('%s_%d', 'Marker', i), MarkerName);
    newMarker.markerTranslation = [0 10 10]+vector_1(1:3);
    newMarker.markerScale=[0.03 0.1 0.1];
    %color table   R   G   B  
    %BLACK         0   0   0    
    %RED         255   0   0    
    %ORAGERED    255  69   0     
    %darkorange1 255 127   0     
    %DARKORANGE  255 140   0   
    %ORANGE      255 165   0   
    %GOLD        255 215   0     
    %YELLOW      255 255   0     
    %LIGHTYELLOW 255 255 224    
    %IVORY       255 255 240     
    %WHITE       255 255 255
    newMarker.markerColor=[255 255 240];
    %vector_3=vector_2;
    vrdrawnow;
 end
    
% Exit gracefully
close(world)
close(figref)
  

