function scoreData = convertOld(scoreDataOld, inName, trainNames)
    numberSets = length(scoreDataOld.predLabel);
    scoreData(numberSets) = getScoreDataStructure();
    for k = 1:numberSets
        scoreData(k).testFileName = inName;
        scoreData(k).trainFileName = trainNames{k};
        scoreData(k).testLabel = scoreDataOld.testLabel;
        scoreData(k).predLabel = scoreDataOld.predLabel{k};
        scoreData(k).testFinalScore = scoreDataOld.testFinalScore{k};
        scoreData(k).testFinalCutoff = scoreDataOld.testFinalCutoff(k);
        scoreData(k).testInitProb = scoreDataOld.testInitProb{k};
        scoreData(k).testInitCutoff = scoreDataOld.testInitCutoff(k);
        scoreData(k).trainLabel = scoreDataOld.trainLabel{k};
        scoreData(k).trainScore = scoreDataOld.trainScore{k};
    end
end

