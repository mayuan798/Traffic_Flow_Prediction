% main.m
clc, clear all; close all;
addpath(genpath('D:\Programming\Github\Traffic_Flow_Prediction\SAE'));

%% configuration structure
% config.data_file
% config.time_intervals
% config.num_TMCs

%% data preparation
dp_flag = 0;                    % data preparation flag
config.time_intervals = 10;     % 10 minutes data
config.data_file = 'Route1RawX';
if ~exist('training_data.mat', 'file') || (1 == dp_flag)
    disp('Generating training dataset.');
    tic;
    try
        parpool;
    catch Me
    end
    config.num_TMCs = prepare_data(config.time_intervals, config.data_file);
    toc;
    delete(gcp);
    save('./data/configuration.mat', 'config');
else
    load('configuration');
end

%% running SAE
load('training_data');
rng('default');     % initialize random seed
disp('Running SAE part');

input_size = config.time_intervals / 2 * config.num_TMCs;
% set the architecture of SAE
hidden_layer = [round(4 / 5 * input_size), round( 3 / 5 * input_size)];
sae = saesetup([input_size, hidden_layer]);

%% sae.ae{k} structure
% sae.ae{k}.activation_fuction:     activation function for autoencoder
% sae.ae{k}.learningRate:           learning rate for autoencoder
% sae.ae{k}.inputZeroMaskedFraction: have no idea

sae.ae{1}.activation_fuction        = 'sigm';
sae.ae{1}.learningRate              = 1;
sae.ae{1}.inputZeroMaskedFraction   = 0.5;

%% NN option structure
% opts.numepochs: number of epochs
% opts.batchsize: the size of batch mode

opts.numepochs                      = 10;
opts.batchsize                      = 10;           

train_x = train_x((1:floor(size(train_x, 1) / opts.batchsize) * opts.batchsize), :);

sae = saetrain(sae, train_x, opts);
save('./output/sae_network.mat', 'sae');


%% when use the feature generated from SAE, please add the following code
% previous three is the SAE layers
% nn = nnsetup([75 60 45 (other neural network layers)]);
% nn.activation_function              = 'sigm';
% nn.learningRate                     = 1;
% nn.W{1} = sae.ae{1}.W{1};
% nn.W{2} = sae.ae{2}.W{1};

