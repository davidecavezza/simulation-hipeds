function [ projectRoot ] = getProjectRoot()
%GETPROJECTROOT Returns the root folder of the simulation project on the
%executing machine (with a final slash)

curDir = pwd;
projectRoot = curDir(1:strfind(curDir,'simulation-hipeds')+length('simulation-hipeds'));


end

