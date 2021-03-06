/****** Object:  StoredProcedure [dbo].[CTHB_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CTHB_RETRIEVE_S16] (
 @Ac_IVDOutOfStateCase_ID   CHAR(15),
 @Ac_IVDOutOfStateFips_CODE CHAR(2)
 )
AS
 /*    
  *     PROCEDURE NAME    : CTHB_RETRIEVE_S16    
  *     DESCRIPTION       : Retrieve Transaction Date, Other Case Idno, Other State Fips Code, and Non Custodial Parent Name for a Other State Fips Code, Other Case Idno, Functoin Code, Action Code, Reason Code, and Transaction Header Id.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Lc_RefAssistR_CODE CHAR(1) = 'R',
          @Li_Zero_NUMB       SMALLINT = 0,
          @Ld_System_DATE     DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT X.Transaction_DATE,
         X.IVDOutOfStateFips_CODE,
         (SELECT S.State_NAME
            FROM STAT_Y1 S
           WHERE S.StateFips_CODE = X.IVDOutOfStateFips_CODE) AS State_NAME,
         X.IVDOutOfStateCase_ID,
         X.Last_NAME,
         X.Middle_NAME,
         X.First_NAME,
         X.Suffix_NAME,
         X.CaseCreate_DATE,
         COUNT(1) OVER() AS RowCount_NUMB
    FROM (SELECT a.Transaction_DATE,
                 a.IVDOutOfStateFips_CODE,
                 a.IVDOutOfStateCase_ID,
                 c.Last_NAME,
                 c.Middle_NAME,
                 c.First_NAME,
                 c.Suffix_NAME,
                 dbo.BATCH_COMMON$SF_CALCULATE_NTH_BDAY(a.Transaction_DATE, 10) AS CaseCreate_DATE
            FROM CTHB_Y1 a
                 JOIN CFAR_Y1 b
                  ON b.Function_CODE = a.Function_CODE
                     AND b.Action_CODE = a.Action_CODE
                     AND b.Reason_CODE = a.Reason_CODE
                 JOIN CNCB_Y1 c
                  ON c.TransHeader_IDNO = a.TransHeader_IDNO
           WHERE a.IVDOutOfStateFips_CODE = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_IVDOutOfStateFips_CODE), a.IVDOutOfStateFips_CODE)
             AND a.IVDOutOfStateCase_ID = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_IVDOutOfStateCase_ID), a.IVDOutOfStateCase_ID)
             AND a.Case_IDNO = @Li_Zero_NUMB
             AND b.RefAssist_CODE = @Lc_RefAssistR_CODE) AS X
   WHERE @Ld_System_DATE >= CaseCreate_DATE
   ORDER BY Transaction_DATE DESC;
 END; --End of CTHB_RETRIEVE_S16    

GO
