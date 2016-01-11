% Free memory and prevent corruption
clear all;

%Parameters for the simulation
t = 0: 0.02*pi : 4*pi;
a = 0.5; b = 1;

% Create a vrworld object and open it
world = vrworld('base_world.wrl', 'new');
open(world);

% Add externproto for straight piece & curve pieces
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

% Create the MATLAB GUI
figure_height=600;
figure_width=600;
corner_x=20;
corner_y=20;
clearance=20;
% GUI
figref = figure('Position',[100 300 figure_width+2*clearance figure_height+2*clearance]);
% Attach VR canvas to the GUI
c1 = vr.canvas(world, gcf, [corner_x corner_y figure_width figure_height]);
% Normalize to allow scaling of the view when the figure window is resized.
set(c1,'Units','normalized')
c1.Viewpoint = 'Overall_View';

pause(3);
    
% save the track
save(world,'new_track.wrl');
% Exit gracefully
close(world)
close(figref)
  

