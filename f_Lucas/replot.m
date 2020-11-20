clear all; close all; clc;

TEB_TAB=[];
TEP_TAB=[];

load('DEBUG_6_31.mat');

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

load('DEBUG_6_32.mat');

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

load('DEBUG_6_33.mat');

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

load('DEBUG_6_34.mat');

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

load('DEBUG_6_35.mat');

TEB_TAB=[TEB_TAB; ber];
TEP_TAB=[TEP_TAB; paquet_err];

figure(5)

semilogy(EbN0dB,TEB_TAB(1,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB(2,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB(3,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB(4,:),'LineWidth',1);hold on;
semilogy(EbN0dB,TEB_TAB(5,:),'LineWidth',1);hold on;

semilogy(EbN0dB,TEP_TAB(1,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB(2,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB(3,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB(4,:),'--','LineWidth',1);hold on;
semilogy(EbN0dB,TEP_TAB(5,:),'--','LineWidth',1);hold on;


xlim([0 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB','Interpreter', 'latex', 'FontSize',14)
title('TEB et TEP pour chaque code');

legend('TEB1','TEB2','TEB3','TEB4','TEB5','TEP1','TEP2','TEP3','TEP4','TEP5')
