/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S9] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S9  
  *     DESCRIPTION       : Retrieve Other State, Other County, and Other Office details for respective Case and Other FIPS Code of a certain status.  
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 27-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Lc_StatusO_CODE        CHAR(1) = 'O',
          @Li_One_NUMB            INT =1,
          @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT i.IVDOutOfStateFips_CODE,
         i.IVDOutOfStateOfficeFips_CODE,
         i.IVDOutOfStateCountyFips_CODE,
         i.State_NAME,
         i.RespondentMci_IDNO
    FROM (SELECT I.IVDOutOfStateFips_CODE,
                 I.IVDOutOfStateOfficeFips_CODE,
                 I.IVDOutOfStateCountyFips_CODE,
                 S.State_NAME,
                 I.RespondentMci_IDNO,
                 ROW_NUMBER() OVER(PARTITION BY IVDOutOfStateFips_CODE ORDER BY Create_DATE DESC, TransactionEventSeq_NUMB DESC) rnm
            FROM ICAS_Y1 I
                 JOIN STAT_Y1 S
                  ON I.IVDOutOfStateFips_CODE = S.StateFips_CODE
           WHERE I.Case_IDNO = @An_Case_IDNO
             AND I.Status_CODE = @Lc_StatusO_CODE
             AND @Ld_Systemdatetime_DTTM BETWEEN I.Effective_DATE AND I.End_DATE
             AND I.EndValidity_DATE = @Ld_High_DATE) i
   WHERE i.rnm = @Li_One_NUMB
   ORDER BY i.State_NAME;
 END; --End Of ICAS_RETRIEVE_S9



GO
