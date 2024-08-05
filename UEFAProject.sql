-- Data Cleaning: Retrieve cleaned match details with associated win type and round information.
SELECT 
    FM.MatchID,
    HomeTeamID,
    AwayTeamID,
    HomeTeamScore,
    AwayTeamScore,
    HomeTeamTotalScore,
    AwayTeamTotalScore,
    WinTypeName,
    WinnerTeamID,
    [Year],
    [Date],
    MatchAttendance,
    StadiumID,
    RoundName
FROM FactMatches FM
LEFT JOIN DimWinType DT
    ON FM.WinTypeID = DT.WinTypeID
LEFT JOIN DimRound DR
    ON FM.RoundID = DR.RoundID;

-- Retrieve detailed team information for home, away, and winner teams.
SELECT *
FROM FactMatches FM
LEFT JOIN DimTeams HDT
    ON FM.HomeTeamID = HDT.TeamID
LEFT JOIN DimTeams ADT
    ON FM.AwayTeamID = ADT.TeamID
LEFT JOIN DimTeams WDT
    ON FM.WinnerTeamID = WDT.TeamID;

-- Retrieve goal details along with player information.
SELECT *
FROM FactGoals FG
LEFT JOIN DimPlayer DP
    ON FG.PlayerID = DP.PlayerID;

-- Retrieve penalty details along with player information.
SELECT *
FROM FactPenalties FP
LEFT JOIN DimPlayer DP
    ON FP.PlayerID = DP.PlayerID;

-- Update team names to current names and filter to only include final matches.
WITH UpdatedTeams AS (
    SELECT
        TeamID,
        CASE
            WHEN TeamName = 'USSR' THEN 'Russia'
            WHEN TeamName = 'West Germany' THEN 'Germany'
            WHEN TeamName = 'Yugoslavia' THEN 'Serbia'
            WHEN TeamName = 'Czechoslovakia' THEN 'Czechia'
            ELSE TeamName
        END AS TeamName
    FROM DimTeams
)
SELECT 
    FM.MatchID,
    HDT.TeamName AS HomeTeamName,
    ADT.TeamName AS AwayTeamName,
    HomeTeamScore,
    AwayTeamScore,
    HomeTeamTotalScore,
    AwayTeamTotalScore,
    WinTypeName,
    WDT.TeamName AS WinnerTeamName,
    [Year],
    [Date],
    MatchAttendance,
    StadiumID,
    RoundName
FROM FactMatches FM
LEFT JOIN DimWinType DT
    ON FM.WinTypeID = DT.WinTypeID
LEFT JOIN DimRound DR
    ON FM.RoundID = DR.RoundID
LEFT JOIN UpdatedTeams HDT
    ON FM.HomeTeamID = HDT.TeamID
LEFT JOIN UpdatedTeams ADT
    ON FM.AwayTeamID = ADT.TeamID
LEFT JOIN UpdatedTeams WDT
    ON FM.WinnerTeamID = WDT.TeamID
WHERE RoundName LIKE 'Final';


-- Final table showing UEFA EURO final matches with details about attendance and match outcomes.
WITH UpdatedTeams AS (
    SELECT
        TeamID,
        CASE
            WHEN TeamName = 'USSR' THEN 'Russia'
            WHEN TeamName = 'West Germany' THEN 'Germany'
            WHEN TeamName = 'Yugoslavia' THEN 'Serbia'
            WHEN TeamName = 'Czechoslovakia' THEN 'Czechia'
            ELSE TeamName
        END AS TeamName
    FROM DimTeams
)
SELECT 
    CONCAT('EURO ', [Year]) AS TournamentName,
    CASE 
        WHEN MatchAttendance < 30000 THEN 'Low Attendance Match'
        WHEN MatchAttendance < 60000 THEN 'Regular Attendance Match'
        ELSE 'High Attendance Match'
    END AS MatchType,
    [Date],
    HDT.TeamName AS HomeTeamName,
    CONCAT(HomeTeamScore, ' - ', AwayTeamScore) AS MatchResult,
    ADT.TeamName AS AwayTeamName,
    WinTypeName,
    CONCAT(HomeTeamTotalScore, ' - ', AwayTeamTotalScore) AS FinalResult,
    WDT.TeamName AS Winner
FROM FactMatches FM
LEFT JOIN DimWinType DT
    ON FM.WinTypeID = DT.WinTypeID
LEFT JOIN DimRound DR
    ON FM.RoundID = DR.RoundID
LEFT JOIN UpdatedTeams HDT
    ON FM.HomeTeamID = HDT.TeamID
LEFT JOIN UpdatedTeams ADT
    ON FM.AwayTeamID = ADT.TeamID
LEFT JOIN UpdatedTeams WDT
    ON FM.WinnerTeamID = WDT.TeamID
WHERE RoundName LIKE 'Final'
ORDER BY TournamentName;

-- Count the number of titles won by each team in final matches.
WITH UpdatedTeams AS (
    SELECT
        TeamID,
        CASE
            WHEN TeamName = 'USSR' THEN 'Russia'
            WHEN TeamName = 'West Germany' THEN 'Germany'
            WHEN TeamName = 'Yugoslavia' THEN 'Serbia'
            WHEN TeamName = 'Czechoslovakia' THEN 'Czechia'
            ELSE TeamName
        END AS TeamName
    FROM DimTeams
),
FinalsWinners AS (
    SELECT 
        FM.WinnerTeamID,
        WT.TeamName
    FROM FactMatches FM
    LEFT JOIN UpdatedTeams WT
        ON FM.WinnerTeamID = WT.TeamID
    LEFT JOIN DimRound DR
        ON FM.RoundID = DR.RoundID
    WHERE DR.RoundName = 'Final'
    AND FM.WinnerTeamID IS NOT NULL
)
SELECT
    FW.TeamName,
    COUNT(*) AS TitlesWon
FROM FinalsWinners FW
GROUP BY FW.TeamName
ORDER BY TitlesWon DESC;

-- Analyze top scorers by counting goals scored by each player.
SELECT
    DP.PlayerName,
    COUNT(*) AS GoalsScored
FROM FactGoals FG
LEFT JOIN DimPlayer DP
    ON FG.PlayerID = DP.PlayerID
GROUP BY DP.PlayerName
ORDER BY GoalsScored DESC;

-- Calculate the average number of goals scored per final match for each tournament year.
SELECT
    CONCAT('EURO ', [Year]) AS TournamentName,
    COUNT(*) AS GoalsInMatch
FROM FactMatches FM
LEFT JOIN FactGoals FG
    ON FM.MatchID = FG.MatchID
LEFT JOIN DimRound DR
    ON FM.RoundID = DR.RoundID
WHERE RoundName = 'Final'
GROUP BY [Year];

-- Identify players who have taken the most penalties.
SELECT
    DP.PlayerName,
    COUNT(*) AS PenaltiesTaken
FROM FactPenalties FP
LEFT JOIN DimPlayer DP
    ON FP.PlayerID = DP.PlayerID
GROUP BY DP.PlayerName
ORDER BY PenaltiesTaken DESC;
