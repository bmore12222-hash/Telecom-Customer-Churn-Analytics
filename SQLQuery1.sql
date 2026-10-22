--1. Basic SQL Data Check--
SELECT *
FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn];

SELECT COUNT(*) AS TotalCustomers
FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn];

--2. Check Duplicate Customers
SELECT
    customerID,
    COUNT(*) AS CustomerCount
FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn]
GROUP BY customerID
HAVING COUNT(*) > 1;

-- 3. Overalll Churn KPI 
SELECT
    COUNT(*) AS TotalCustomers,

    SUM(
        CASE
            WHEN Churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS ChurnedCustomers,

    CAST(
        100.0 *
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ChurnRate
FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn];

-- 4. Churn by Contract
SELECT
    Contract,
    COUNT(*) AS Customers,

    SUM(
        CASE
            WHEN Churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS ChurnedCustomers,

    CAST(
        100.0 *
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ChurnRate

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn]

GROUP BY Contract

ORDER BY ChurnRate DESC;

-- 5. Churn by Tenure
SELECT
    CASE
        WHEN tenure <= 6 THEN '0-6'
        WHEN tenure <= 12 THEN '7-12'
        WHEN tenure <= 24 THEN '13-24'
        WHEN tenure <= 48 THEN '25-48'
        WHEN tenure <= 60 THEN '49-60'
        ELSE '61-72'
    END AS TenureBand,

    COUNT(*) AS Customers,

    SUM(
        CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END
    ) AS ChurnedCustomers,

    CAST(
        100.0 *
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ChurnRate

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn]

GROUP BY
    CASE
        WHEN tenure <= 6 THEN '0-6'
        WHEN tenure <= 12 THEN '7-12'
        WHEN tenure <= 24 THEN '13-24'
        WHEN tenure <= 48 THEN '25-48'
        WHEN tenure <= 60 THEN '49-60'
        ELSE '61-72'
    END

ORDER BY ChurnRate DESC;

-- 6. Churn by Payment Method -- 
SELECT
    PaymentMethod,

    COUNT(*) AS Customers,

    SUM(
        CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END
    ) AS ChurnedCustomers,

    CAST(
        100.0 *
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ChurnRate

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn]

GROUP BY PaymentMethod

ORDER BY ChurnRate DESC;

--7. Churn by Internet Service
SELECT
    InternetService,
    COUNT(*) AS Customers,

    SUM(
        CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END
    ) AS ChurnedCustomers,

    CAST(
        100.0 *
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ChurnRate

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn]

GROUP BY InternetService

ORDER BY ChurnRate DESC;

-- 8.Revenue Lost From Churn --
SELECT
    SUM(
        CASE
            WHEN Churn = 'Yes'
            THEN MonthlyCharges
            ELSE 0
        END
    ) AS MonthlyRevenueLost

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn];

-- 9. Revenue Lost by Contract --
SELECT
    Contract,

    COUNT(*) AS ChurnedCustomers,

    SUM(
        CASE
            WHEN Churn = 'Yes'
            THEN MonthlyCharges
            ELSE 0
        END
    ) AS MonthlyRevenueLost

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn]

GROUP BY Contract

ORDER BY MonthlyRevenueLost DESC;

-- 10. Customer Segmentation Query -- 
SELECT
    customerID,
    tenure,
    MonthlyCharges,
    Contract,
    PaymentMethod,
    InternetService,
    Churn,

    CASE
        WHEN tenure <= 6
             AND Contract = 'Month-to-month'
             AND MonthlyCharges >= 70
            THEN 'High Risk'

        WHEN tenure <= 12
             AND Contract = 'Month-to-month'
            THEN 'Medium-High Risk'

        WHEN Contract = 'Month-to-month'
            THEN 'Medium Risk'

        WHEN Contract IN ('One year', 'Two year')
            THEN 'Low Risk'

        ELSE 'Standard'
    END AS RiskSegment

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn];

-- 11. Find Your Highest-Risk Customers
SELECT
    customerID,
    tenure,
    MonthlyCharges,
    Contract,
    PaymentMethod,
    InternetService,
    RiskSegment

FROM
(
    SELECT
        customerID,
        tenure,
        MonthlyCharges,
        Contract,
        PaymentMethod,
        InternetService,

        CASE
            WHEN tenure <= 6
                 AND Contract = 'Month-to-month'
                 AND MonthlyCharges >= 70
                THEN 'High Risk'

            WHEN tenure <= 12
                 AND Contract = 'Month-to-month'
                THEN 'Medium-High Risk'

            WHEN Contract = 'Month-to-month'
                THEN 'Medium Risk'

            ELSE 'Low Risk'
        END AS RiskSegment

    FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn]
) x

WHERE RiskSegment = 'High Risk'

ORDER BY MonthlyCharges DESC;

-- 12.Top Revenue-at-Risk Segments --
SELECT
    Contract,
    InternetService,
    PaymentMethod,

    COUNT(*) AS Customers,

    SUM(
        CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END
    ) AS ChurnedCustomers,

    SUM(MonthlyCharges) AS MonthlyRevenue,

    SUM(
        CASE
            WHEN Churn = 'Yes'
            THEN MonthlyCharges
            ELSE 0
        END
    ) AS RevenueLost

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn]

GROUP BY
    Contract,
    InternetService,
    PaymentMethod

ORDER BY RevenueLost DESC;

-- PHASE 4 — Create SQL Views --
CREATE VIEW vw_ChurnSummary AS

SELECT
    COUNT(*) AS TotalCustomers,

    SUM(
        CASE WHEN Churn = 'Yes'
        THEN 1 ELSE 0 END
    ) AS ChurnedCustomers,

    CAST(
        100.0 *
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ChurnRate,

    SUM(MonthlyCharges) AS TotalMonthlyRevenue,

    SUM(
        CASE WHEN Churn = 'Yes'
        THEN MonthlyCharges ELSE 0 END
    ) AS MonthlyRevenueLost

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn];

SELECT *
FROM vw_ChurnSummary;

-- Create Churn Segment View --
CREATE VIEW vw_ChurnAnalysis AS

SELECT
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    MonthlyCharges,
    TotalCharges,
    Churn,

    CASE
        WHEN tenure <= 6 THEN '0-6'
        WHEN tenure <= 12 THEN '7-12'
        WHEN tenure <= 24 THEN '13-24'
        WHEN tenure <= 48 THEN '25-48'
        WHEN tenure <= 60 THEN '49-60'
        ELSE '61-72'
    END AS TenureBand,

    CASE
        WHEN Churn = 'Yes' THEN 1
        ELSE 0
    END AS ChurnFlag

FROM dbo.[WA_Fn-UseC_-Telco-Customer-Churn];