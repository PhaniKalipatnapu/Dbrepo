/****** Object:  StoredProcedure [dbo].[ACEN_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACEN_RETRIEVE_S6] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_StatusEnforce_CODE       CHAR(1) OUTPUT,
 @Ac_ReasonStatus_CODE        CHAR(2) OUTPUT,
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : ACEN_RETRIEVE_S6  
  *     DESCRIPTION       : Retrieve Case Enforcement Status, Update Reason status, Active NON-Voluntary Order status, Support Status and Transaction Sequence Number for a Case ID.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ac_StatusEnforce_CODE = NULL,
         @Ai_Count_QNTY = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_ReasonStatus_CODE = NULL;

  DECLARE @Lc_TypeOrderVoluntary_CODE CHAR(1)	= 'V',
          @Ld_High_DATE               DATE		= '12/31/9999';
  DECLARE @Ld_Today_DATE			  DATE		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ac_StatusEnforce_CODE = a.StatusEnforce_CODE,
         @Ac_ReasonStatus_CODE = a.ReasonStatus_CODE,
         @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB,
         @Ai_Count_QNTY = (SELECT COUNT(1)
                             FROM SORD_Y1 S
                            WHERE S.Case_IDNO = a.Case_IDNO
                              AND S.OrderSeq_NUMB = a.OrderSeq_NUMB
                              AND S.EndValidity_DATE = @Ld_High_DATE
                              AND S.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
                              AND @Ld_Today_DATE BETWEEN S.OrderEffective_DATE AND S.OrderEnd_DATE)
    FROM ACEN_Y1 a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End of ACEN_RETRIEVE_S6 


GO
