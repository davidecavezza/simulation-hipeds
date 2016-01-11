function [ typeMap ] = getTypeMap()
%% For each attribute in VRML, returns one of the following types: 
%% single, 
%% vector,
%% string,
%% object, 
%% valueArray,
%% objectArray

keys = {'translation','center','rotation', ...
            'scale','scaleOrientation','children','size',...
            'point','material','texture','textureTransform',...
            'solid','convex','coord','coordIndex',...
            'ambientIntensity','diffuseColor','emissiveColor',...
            'shininess','specularColor','transparency',...
            'appearance','geometry',...
            };
values = {'vector','vector','vector', ...
            'vector','vector','objectArray','vector', ...
            'valueArray','object','object','object',...
            'string','string','object','valueArray',...
            'single','vector','vector',...
            'single','vector','single',...
            'object','object',...
            };

typeMap = containers.Map(keys,values);


end
