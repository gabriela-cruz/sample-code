% Select clusters
Clusters2plot = 6; %[6 19 13 4 15]; 
  
% project lines
STUDY.etc.dipparams.projlines = 'off'; %on

% indicate groups and colour
Groups     = {'1' ; '2' ; '3' ; '4'};
GroupColor = {'r' ; 'g' ; 'b' ; 'y'};


  for i = 1:length(Clusters2plot)
      
      cluster = Clusters2plot(i);
      
      ndip    = length(STUDY.cluster(cluster).comps);
                  
      % Get dipole location info for each component
      for k = 1:ndip
       
       abset   = STUDY.datasetinfo(STUDY.cluster(cluster).sets(1,k)).index;%subject index for example: 4
       subject = STUDY.datasetinfo(STUDY.cluster(cluster).sets(1,k)).subject; %subject ID for example 'Subj4'   
       comp = STUDY.cluster(cluster).comps(k); %components for example [1 2 5 9 10]
       cluster_dip_models(k).posxyz = ALLEEG(abset).dipfit.model(comp).posxyz;
       cluster_dip_models(k).momxyz = ALLEEG(abset).dipfit.model(comp).momxyz;
       cluster_dip_models(k).rv = ALLEEG(abset).dipfit.model(comp).rv;
       comp_to_disp{k} = [subject  ', ' 'IC' num2str(comp) ];
       comp_group{k}   = STUDY.datasetinfo(STUDY.cluster(cluster).sets(1,k)).group; % Indicate group label for each component. You must have that info in the structure 
      
      end
      
      
      opt_dipplot = {'projlines',STUDY.etc.dipparams.projlines, 'axistight', STUDY.etc.dipparams.axistight, 'projimg', STUDY.etc.dipparams.projimg, 'normlen', 'on', 'pointout', 'on', 'verbose', 'off', 'dipolelength', 0,'spheres','on'};
      
      dip_color = cell(1,ndip); % use ndip+1 if ploting centroid
      for c = 1:length(Groups)
          dip_color(find(ismember(comp_group,Groups{c}))) = {GroupColor{c}}; 
      end
      %dip_color(end) = {'r'}; color of the centroid
      
      options = opt_dipplot;
      options{end+1} =  'mri';
      options{end+1} =  ALLEEG(abset).dipfit.mrifile;
      options{end+1} =  'coordformat';
      options{end+1} =  ALLEEG(abset).dipfit.coordformat;
      options{end+1} =  'dipnames';
      options{end+1} =  {comp_to_disp{:}} ; %cellstr(int2str([1:ndip]'))' ; % {comp_to_disp{:} [STUDY.cluster(cls(clus)).name ' mean']}; name of the comp plus mean
      options{end+1} = 'color';
      options{end+1} = dip_color;
       
      %===============================
      %use to calculate centroid
      %[cluster_dip_models, options] = dipgroups(ALLEEG, STUDY, cluster, comp_to_disp, cluster_dip_models, options); 
      %cluster_dip_models(end + 1) = STUDY.cluster(cluster).dipole;
      %===============================
      
      dipplot(cluster_dip_models, options{:}); %'holdon',holdon{i})
      % Manually adjust linewidth in diplot.m line 779 to 759
  
  
  
  end
  
  
  
  %%
    
  % first plot the dipoles through the GUI or using std_dipplot, to
  % calculate the dipole centroid
%   for i = 1:length(Clusters2plot)
%       
%       cluster = Clusters2plot(i);
%       
%       STUDY = std_dipplot(STUDY,ALLEEG,'clusters',cluster);
%       close all
%   end
%   
  
  
  
  
  
  