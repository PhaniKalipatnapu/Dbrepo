/****** Object:  StoredProcedure [dbo].[USES_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USES_RETRIEVE_S1] (
 @Ac_Worker_ID                CHAR(30) = NULL,
 @As_ESignature_BIN			  VARCHAR(4000) OUTPUT,
 @Ad_BeginValidity_DATE       DATE OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : USES_RETRIEVE_S1  
  *     DESCRIPTION       : Retrieve the electronic signature information about worker like line1, line2, line 3 information of the worker,
  *							expiry date, pin text, begin validity and worker updated infromation.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/07/2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0  
 */
 BEGIN
  SELECT @As_ESignature_BIN = NULL,
         @Ad_BeginValidity_DATE = NULL,
         @Ac_WorkerUpdate_ID = NULL;

  SELECT TOP 1 @As_ESignature_BIN = CONVERT(VARCHAR(4000),a.ESignature_BIN),
               @Ac_WorkerUpdate_ID = a.WorkerUpdate_ID,
               @Ad_BeginValidity_DATE = a.BeginValidity_DATE,
               @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
    FROM USES_Y1 a
   WHERE a.Worker_ID = @Ac_Worker_ID;
 END


GO
