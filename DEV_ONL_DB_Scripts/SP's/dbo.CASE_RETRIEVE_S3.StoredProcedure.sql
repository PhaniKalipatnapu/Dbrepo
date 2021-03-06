/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S3](
  @An_Office_IDNO  NUMERIC(3),
  @An_Case_IDNO    NUMERIC(6),
  @Ac_Role_ID      CHAR(10),
  @Ac_Worker_ID    CHAR(30),
  @Ai_RowFrom_NUMB INT,
  @Ai_RowTo_NUMB   INT)
AS
  /*   
  *     PROCEDURE NAME    : CASE_RETRIEVE_S1   
  *     DESCRIPTION       : Retrieve Case details, Member details, Custodial Parent Name, and Non Custodial Parent Name for an Office, Case Idno, Docket Idno, Role Idno, and where Case Status is Open.  
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 02-SEP-2011   
  *     MODIFIED BY       :    
  *     MODIFIED ON       :    
  *     VERSION NO        : 1   
  */
  BEGIN
    DECLARE
      @Li_Zero_NUMB		                 INT			= 0,
      @Lc_Yes_TEXT                       CHAR(1)		= 'Y',
      @Lc_No_TEXT                        CHAR(1)		= 'N',
      @Lc_CpCaseRelationship_CODE        CHAR(1)		= 'C',
      @Lc_NcpCaseRelationship_CODE       CHAR(1)		= 'A',
      @Lc_PutFatherCaseRelationship_CODE CHAR(1)		= 'P',
      @Lc_ActiveStatusCase_CODE          CHAR(1)		= 'A',
      @Lc_OpenCaseStatus_CODE            CHAR(1)		= 'O',
      @Lc_ChildSupportSupervisorRole_ID  CHAR(10)		= 'RP004',
      @Ld_High_DATE                      DATE			= '12/31/9999';
    DECLARE
      @Ld_Current_DATE                   DATE			= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
      

    WITH Case_CTE
         AS (SELECT X.Worker_ID,
                    X.Case_IDNO,
                    X.File_ID,
                    X.TypeCase_CODE,
                    X.RespondInit_CODE,
                    X.TransactionEventSeq_NUMB,
                    X.Row_NUMB,
                    X.RowCount_NUMB
               FROM (SELECT w.Worker_ID,
                            a.Case_IDNO,
                            a.File_ID,
                            a.TypeCase_CODE,
                            a.RespondInit_CODE,
                            a.TransactionEventSeq_NUMB,
                            COUNT(1) OVER() AS RowCount_NUMB,
                            ROW_NUMBER() OVER( ORDER BY w.Worker_ID, a.Case_IDNO, a.TransactionEventSeq_NUMB) AS Row_NUMB
                       FROM CASE_Y1 a
                       JOIN CWRK_Y1 w
                         ON w.Case_IDNO=a.Case_IDNO
                        AND w.Office_IDNO=a.Office_IDNO
                        AND w.Role_ID=@Ac_Role_ID
                        AND w.Expire_DATE>@Ld_Current_DATE
                        AND w.EndValidity_DATE=@Ld_High_DATE
                        AND w.Role_ID!=@Lc_ChildSupportSupervisorRole_ID
                        AND w.Worker_ID=ISNULL(@Ac_Worker_ID, w.Worker_ID)
                      WHERE a.Office_IDNO=@An_Office_IDNO
                        AND a.StatusCase_CODE=@Lc_OpenCaseStatus_CODE
                        AND a.Case_IDNO=ISNULL(@An_Case_IDNO, a.Case_IDNO)) X
              WHERE X.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB)
    SELECT CTE.Case_IDNO,
           (SELECT TOP 1 MHX.CaseWelfare_IDNO
              FROM (SELECT MH.CaseWelfare_IDNO,
                           ROW_NUMBER() OVER( ORDER BY MH.Start_DATE DESC) AS ORD_ROWNUM
                      FROM MHIS_Y1 MH
                     WHERE MH.Case_IDNO=CTE.Case_IDNO
                       AND MH.CaseWelfare_IDNO!= @Li_Zero_NUMB) MHX) AS CaseWelfare_IDNO,
           ISNULL((SELECT MAX(CASE
                               WHEN UR.HighProfile_INDC=@Lc_Yes_TEXT
                                     OR UR.Familial_INDC=@Lc_Yes_TEXT
                               THEN @Lc_Yes_TEXT
                               ELSE @Lc_No_TEXT
                              END)
                     FROM (SELECT UR.HighProfile_INDC,
                                  UR.Familial_INDC,
                                  ROW_NUMBER() OVER(ORDER BY UR.TransactionEventSeq_NUMB DESC ) Row_NUMB
                             FROM USRT_Y1 UR
                            WHERE UR.Case_IDNO=CTE.Case_IDNO
                              AND UR.EndValidity_DATE=@Ld_High_DATE) UR
                    WHERE UR.Row_NUMB=1), @Lc_No_TEXT) AS CaseRestriction_CODE,
           CTE.File_ID,
           CTE.TypeCase_CODE,
           CTE.RespondInit_CODE,
           CTE.Worker_ID,
           CTE.TransactionEventSeq_NUMB,
           CPD.First_NAME AS CpFirst_NAME,
           CPD.Middle_NAME AS CpMiddle_NAME,
           CPD.Last_NAME AS CpLast_NAME,
           NCD.First_NAME AS NcpFirst_NAME,
           NCD.Middle_NAME AS NcpMiddle_NAME,
           NCD.Last_NAME AS NcpLast_NAME,
           CTE.RowCount_NUMB
      FROM Case_CTE CTE
           OUTER APPLY (SELECT CPD.First_NAME,
                               CPD.Middle_NAME,
                               CPD.Last_NAME
                          FROM CMEM_Y1 CPM,
                               DEMO_Y1 CPD
                         WHERE CTE.Case_IDNO=CPM.Case_IDNO
                           AND CPM.MemberMci_IDNO=CPD.MemberMci_IDNO
                           AND CPM.CaseRelationship_CODE=@Lc_CpCaseRelationship_CODE
                           AND CPM.CaseMemberStatus_CODE=@Lc_ActiveStatusCase_CODE) CPD
           OUTER APPLY (SELECT TOP 1 NCPD.First_NAME,
                                     NCPD.Middle_NAME,
                                     NCPD.Last_NAME
                          FROM CMEM_Y1 NCPM,
                               DEMO_Y1 NCPD
                         WHERE CTE.Case_IDNO=NCPM.Case_IDNO
                           AND NCPM.MemberMci_IDNO=NCPD.MemberMci_IDNO
                           AND NCPM.CaseRelationship_CODE IN (
                               @Lc_NcpCaseRelationship_CODE, @Lc_PutFatherCaseRelationship_CODE)
                           AND NCPM.CaseMemberStatus_CODE=@Lc_ActiveStatusCase_CODE
                         ORDER BY NCPM.CaseRelationship_CODE) NCD
     ORDER BY cte.Row_NUMB;
  END


GO
