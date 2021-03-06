/****** Object:  StoredProcedure [dbo].[CSPR_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSPR_RETRIEVE_S12](
 @An_Case_IDNO                    NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE       CHAR(2),
 @Ac_IVDOutOfStateCountyFips_CODE CHAR(3),
 @Ac_IVDOutOfStateOfficeFips_CODE CHAR(2),
 @Ac_Reason_CODE                  CHAR(5),
 @Ac_WorkerUpdate_ID              CHAR(30),
 @Ac_Exists_INDC                  CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CSPR_RETRIEVE_S12
  *     DESCRIPTION       : Retrieve the count of records from Csenet Pending Requests table for the Action code for which this request is made equal to PENDING (P) and for the retrieved information such as case ID for which this request is created for CSENET communications, Interstate Case FIPS Code, Interstate Case State, the SET reason code and Interstate Case County.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 13-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_ActionPending_CODE CHAR(1) = 'P',
          @Ld_High_DATE          DATE = '12/31/9999',
          @Ld_Current_DATE       DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_Yes_INDC           CHAR(1) = 'Y',
          @Lc_No_INDC            CHAR(1) = 'N';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM CSPR_Y1 PR
   WHERE PR.WorkerUpdate_ID = @Ac_WorkerUpdate_ID
     AND PR.Case_IDNO = @An_Case_IDNO
     AND PR.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND PR.IVDOutOfStateCountyFips_CODE = @Ac_IVDOutOfStateCountyFips_CODE
     AND PR.IVDOutOfStateOfficeFips_CODE = @Ac_IVDOutOfStateOfficeFips_CODE
     AND PR.Reason_CODE = @Ac_Reason_CODE
     AND PR.Action_CODE = @Lc_ActionPending_CODE
     AND PR.BeginValidity_DATE = @Ld_Current_DATE
     AND PR.EndValidity_DATE = @Ld_High_DATE;
 END -- End of CSPR_RETRIEVE_S12

GO
