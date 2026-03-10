
%% Create variables of interest (VoiceTGype, Emotion, MaxVelocity)
Naturals=allFrameData(contains(allFrameData(:,6),'natural'),:);
MeanMaxVelocityNatural=mean(cell2mat(Naturals(:,15)));

NaturalAnger=Naturals(contains(Naturals(:,8),'anger'),:);
NaturalNeutral=Naturals(contains(Naturals(:,8),'neutral'),:);
NaturalHappiness=Naturals(contains(Naturals(:,8),'happiness'),:);
NaturalPleasure=Naturals(contains(Naturals(:,8),'pleasure'),:);
MeanMaxVelocityNaturalAnger=mean(cell2mat(NaturalAnger(:,15)));
MeanMaxVelocityNaturalHappiness=mean(cell2mat(NaturalHappiness(:,15)));
MeanMaxVelocityNaturalNeutral=mean(cell2mat(NaturalNeutral(:,15)));
MeanMaxVelocityNaturalPleasure=mean(cell2mat(NaturalPleasure(:,15)));
MeanMaxVelocNaturalEmotions=[MeanMaxVelocityNaturalAnger,MeanMaxVelocityNaturalHappiness,...
    MeanMaxVelocityNaturalPleasure,MeanMaxVelocityNaturalNeutral];


SyntheticNoise=allFrameData(contains(allFrameData(:,6),'synthetic_noise'),:);
SyntheticSpectrum=allFrameData(contains(allFrameData(:,6),'synthetic_unknown'),:);
MeanMaxVelocitySyntheticNoise=mean(cell2mat(SyntheticNoise(:,15)));
MeanMaxVelocitySyntheticSpectrum=mean(cell2mat(SyntheticSpectrum(:,15)));

SyntheticNoiseAnger=SyntheticNoise(contains(SyntheticNoise(:,8),'anger'),:);
SyntheticNoiseNeutral=SyntheticNoise(contains(SyntheticNoise(:,8),'neutral'),:);
SyntheticNoiseHappiness=SyntheticNoise(contains(SyntheticNoise(:,8),'happiness'),:);
SyntheticNoisePleasure=SyntheticNoise(contains(SyntheticNoise(:,8),'pleasure'),:);
MeanMaxVelocitySyntheticNoiseAnger=mean(cell2mat(SyntheticNoiseAnger(:,15)));
MeanMaxVelocitySyntheticNoiseHappiness=mean(cell2mat(SyntheticNoiseHappiness(:,15)));
MeanMaxVelocitySyntheticNoiseNeutral=mean(cell2mat(SyntheticNoiseNeutral(:,15)));
MeanMaxVelocitySyntheticNoisePleasure=mean(cell2mat(SyntheticNoisePleasure(:,15)));
MeanMaxVelocSynthNoiseEmotions=[MeanMaxVelocitySyntheticNoiseAnger,MeanMaxVelocitySyntheticNoiseHappiness,...
    MeanMaxVelocitySyntheticNoisePleasure,MeanMaxVelocitySyntheticNoiseNeutral];

SyntheticSpectrumAnger=SyntheticSpectrum(contains(SyntheticSpectrum(:,8),'anger'),:);
SyntheticSpectrumNeutral=SyntheticSpectrum(contains(SyntheticSpectrum(:,8),'neutral'),:);
SyntheticSpectrumHappiness=SyntheticSpectrum(contains(SyntheticSpectrum(:,8),'happiness'),:);
SyntheticSpectrumPleasure=SyntheticSpectrum(contains(SyntheticSpectrum(:,8),'pleasure'),:);
MeanMaxVelocitySyntheticSpectrumAnger=mean(cell2mat(SyntheticSpectrumAnger(:,15)));
MeanMaxVelocitySyntheticSpectrumHappiness=mean(cell2mat(SyntheticSpectrumHappiness(:,15)));
MeanMaxVelocitySyntheticSpectrumNeutral=mean(cell2mat(SyntheticSpectrumNeutral(:,15)));
MeanMaxVelocitySyntheticSpectrumPleasure=mean(cell2mat(SyntheticSpectrumPleasure(:,15)));
MeanMaxVelocSynthSpectrEmotions=[MeanMaxVelocitySyntheticSpectrumAnger,MeanMaxVelocitySyntheticSpectrumHappiness,...
    MeanMaxVelocitySyntheticSpectrumPleasure,MeanMaxVelocitySyntheticSpectrumNeutral];


MatrixForANOVA=[NaturalAnger(:,[6,8,12,15]); NaturalNeutral(:,[6,8,12,15]);NaturalHappiness(:,[6,8,12,15]);...
    NaturalPleasure(:,[6,8,12,15]);...
    SyntheticSpectrumAnger(:,[6,8,12,15]); SyntheticSpectrumNeutral(:,[6,8,12,15]);...
    SyntheticSpectrumHappiness(:,[6,8,12,15]); SyntheticSpectrumPleasure(:,[6,8,12,15]);...
    SyntheticNoiseAnger(:,[6,8,12,15]); SyntheticNoiseNeutral(:,[6,8,12,15]);...
    SyntheticNoiseHappiness(:,[6,8,12,15]); SyntheticNoisePleasure(:,[6,8,12,15])];
writecell(MatrixForANOVA,'E:\Dropbox\LeuchterGrandjean_lc_sg\p01__26092024\MatrixForANOVA.xlsx')

MatrixForR=[NaturalAnger(:,[1:10,15]); NaturalNeutral(:,[1:10,15]);NaturalHappiness(:,[1:10,15]);...
    NaturalPleasure(:,[1:10,15]);...
    SyntheticSpectrumAnger(:,[1:10,15]); SyntheticSpectrumNeutral(:,[1:10,15]);...
    SyntheticSpectrumHappiness(:,[1:10,15]); SyntheticSpectrumPleasure(:,[1:10,15]);...
    SyntheticNoiseAnger(:,[1:10,15]); SyntheticNoiseNeutral(:,[1:10,15]);...
    SyntheticNoiseHappiness(:,[1:10,15]); SyntheticNoisePleasure(:,[1:10,15])];
writecell(MatrixForR,'E:\Dropbox\LeuchterGrandjean_lc_sg\p01__26092024\MatrixForR.xlsx')

%% Figure1: VoiceType
TheVoiceTypesMeanMaxVelocity=[MeanMaxVelocityNatural, MeanMaxVelocitySyntheticNoise, MeanMaxVelocitySyntheticSpectrum];
figure; bar(TheVoiceTypesMeanMaxVelocity)

%% Figure2: VoiceType * Emotion
%MeanMaxVelocNaturalEmotions,MeanMaxVelocSynthNoiseEmotions,MeanMaxVelocSynthSpectrEmotions
figure; hold on; bar(MeanMaxVelocNaturalEmotions);
bar(MeanMaxVelocSynthNoiseEmotions);
bar(MeanMaxVelocSynthSpectrEmotions);

figure; hold on; boxplot(MeanMaxVelocNaturalEmotions);
boxplot(MeanMaxVelocSynthNoiseEmotions);
boxplot(MeanMaxVelocSynthSpectrEmotions);




