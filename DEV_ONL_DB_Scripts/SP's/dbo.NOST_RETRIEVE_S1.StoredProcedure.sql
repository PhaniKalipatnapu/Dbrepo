/****** Object:  StoredProcedure [dbo].[NOST_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOST_RETRIEVE_S1] (
 @Ac_Worker_ID          CHAR(30) = NULL,
 @As_Line1_TEXT         VARCHAR(100) OUTPUT,
 @As_Line2_TEXT         VARCHAR(100) OUTPUT,
 @As_Line3_TEXT         VARCHAR(100) OUTPUT,
 @Ad_Expiry_DATE        DATE OUTPUT,
 @As_Pin_TEXT           VARCHAR(64) OUTPUT,
 @Ad_BeginValidity_DATE DATE OUTPUT,
 @Ac_WorkerUpdate_ID    CHAR(30) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : NOST_RETRIEVE_S1  
  *     DESCRIPTION       : Retrieve the Notary information about worker like line1, line2, line 3 information of the worker,
  *							expiry date, pin text, begin validity and worker updated infromation.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 10/28/2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0  
 */
 BEGIN
  SELECT @Ad_Expiry_DATE = NULL,
         @Ad_BeginValidity_DATE = NULL,
         @As_Line3_TEXT = NULL,
         @As_Line1_TEXT = NULL,
         @As_Pin_TEXT = NULL,
         @As_Line2_TEXT = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @An_TransactionEventSeq_NUMB = NULL;

  SELECT TOP 1 @As_Line1_TEXT = a.Line1_TEXT,
               @As_Line2_TEXT = a.Line2_TEXT,
               @As_Line3_TEXT = a.Line3_TEXT,
               @As_Pin_TEXT = a.Pin_TEXT,
               @Ac_WorkerUpdate_ID = a.WorkerUpdate_ID,
               @Ad_Expiry_DATE = a.Expiry_DATE,
               @Ad_BeginValidity_DATE = a.BeginValidity_DATE,
               @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
    FROM NOST_Y1 a
   WHERE a.Worker_ID = @Ac_Worker_ID;
 END


GO
