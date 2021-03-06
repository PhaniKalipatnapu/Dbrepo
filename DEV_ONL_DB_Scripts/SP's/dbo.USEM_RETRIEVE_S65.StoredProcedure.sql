/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S65]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S65] (
 @Ac_SearchWorker_ID          CHAR(30) = NULL,
 @Ac_SearchLast_NAME          CHAR(20) = NULL,
 @An_SearchOffice_IDNO        NUMERIC(3),
 @Ac_Worker_ID                CHAR(30) OUTPUT,
 @Ac_Last_NAME                CHAR(20) OUTPUT,
 @Ac_Suffix_NAME              CHAR(4) OUTPUT,
 @Ac_First_NAME               CHAR(16) OUTPUT,
 @Ac_Middle_NAME              CHAR(20) OUTPUT,
 @Ac_WorkerTitle_CODE         CHAR(2) OUTPUT,
 @Ac_WorkerSubTitle_CODE      CHAR(2) OUTPUT,
 @Ac_Organization_NAME        CHAR(25) OUTPUT,
 @As_Contact_EML              VARCHAR(100) OUTPUT,
 @Ad_BeginEmployment_DATE     DATE OUTPUT,
 @Ad_EndEmployment_DATE       DATE OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : USEM_RETRIEVE_S65  
  *     DESCRIPTION       : Retrieve the primary information about worker like First Name, 
  *                          Middle Name, Last Name, Worker Title, Worker Sub-Title,
  *                          Organization etc for a Worker ID, 
  *                          Last Name of the Worker .  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/11/2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0  
 */
 BEGIN
  SELECT @Ad_BeginEmployment_DATE = NULL,
         @Ad_EndEmployment_DATE = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @As_Contact_EML = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ac_Organization_NAME = NULL,
         @Ac_WorkerTitle_CODE = NULL,
         @Ac_WorkerSubTitle_CODE = NULL,
         @Ac_Worker_ID = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_Last_NAME = a.Last_NAME,
               @Ac_Suffix_NAME = a.Suffix_NAME,
               @Ac_First_NAME = a.First_NAME,
               @Ac_Middle_NAME = a.Middle_NAME,
               @Ac_WorkerTitle_CODE = a.WorkerTitle_CODE,
               @Ac_WorkerSubTitle_CODE = a.WorkerSubTitle_CODE,
               @Ac_Organization_NAME = a.Organization_NAME,
               @As_Contact_EML = a.Contact_EML,
               @Ad_BeginEmployment_DATE = a.BeginEmployment_DATE,
               @Ad_EndEmployment_DATE = a.EndEmployment_DATE,
               @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB,
               @Ac_Worker_ID = a.Worker_ID
    FROM USEM_Y1 a
   WHERE a.Worker_ID = ISNULL(@Ac_SearchWorker_ID, a.Worker_ID)
     AND a.Last_NAME = ISNULL(@Ac_SearchLast_NAME, a.Last_NAME)
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND a.Worker_ID IN (SELECT b.Worker_ID
                           FROM UASM_Y1 b
                          WHERE b.Office_IDNO = @An_SearchOffice_IDNO
                            AND b.EndValidity_DATE = @Ld_High_DATE);
 END


GO
