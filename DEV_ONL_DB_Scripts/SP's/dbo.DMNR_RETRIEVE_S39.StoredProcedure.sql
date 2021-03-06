/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S39]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S39](
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : DMNR_RETRIEVE_S39
  *     DESCRIPTION       : Retrieves Case Id, order sequence number created for a support order of a case, sequence number for the Remedy and Case / Order combination, Sequence number for  Minor Activity, Transaction Event Sequence for the given Case Id where the Status of the Case is Open, Major Activity code is 'CASE', Current Status of the Minor Activity is Start and Not exists  a record in CrossReasonCodesRef Table where process for which type and reason is cross referenced is 'NOTE' and the  reason code for the corresponding code type value is equal to Minor Activity Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE    CHAR(1) = 'O',
          @Lc_ActivityMajorCase_CODE CHAR(4) = 'CASE',
          @Lc_StatusStart_CODE       CHAR(4) = 'STRT',
          @Lc_ProcessNote_ID         CHAR(3) = 'NOTE';

  SELECT D.Case_IDNO,
         D.OrderSeq_NUMB,
         D.MajorIntSeq_NUMB,
         D.MinorIntSeq_NUMB,
         D.TransactionEventSeq_NUMB
    FROM DMNR_Y1 D
         JOIN CASE_Y1 C
          ON (C.Case_IDNO = D.Case_IDNO)
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
     AND D.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
     AND D.Status_CODE = @Lc_StatusStart_CODE
     AND NOT EXISTS (SELECT 1
                       FROM RESF_Y1 R
                      WHERE R.Process_ID = @Lc_ProcessNote_ID
                        AND R.Reason_CODE = D.ActivityMinor_CODE);
 END; -- End Of DMNR_RETRIEVE_S39 

GO
