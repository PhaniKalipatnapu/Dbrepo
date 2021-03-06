/****** Object:  StoredProcedure [dbo].[DMJR_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DMJR_INSERT_S1] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_Subsystem_CODE           CHAR(2),
 @Ac_TypeOthpSource_CODE      CHAR(1),
 @An_OthpSource_IDNO          NUMERIC(10),
 @Ac_Status_CODE              CHAR(4),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @Ad_BeginExempt_DATE         DATETIME2,
 @Ad_EndExempt_DATE           DATETIME2,
 @An_TotalTopics_QNTY         NUMERIC(10),
 @An_PostLastPoster_IDNO      NUMERIC(10),
 @As_SubjectLastPoster_TEXT   VARCHAR(300),
 @Ad_LastPost_DTTM            DATETIME2,
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_TypeReference_CODE       CHAR(5),
 @Ac_Reference_ID             CHAR(30),
 @An_Forum_IDNO               NUMERIC(10) OUTPUT
 )
AS
 /*                                                                                                                    
  *     PROCEDURE NAME    : DMJR_INSERT_S1                                                                             
  *     DESCRIPTION       : Insert Major Activity reference details with the provided values.                          
  *     DEVELOPED BY      : IMP Team                                                                                   
  *     DEVELOPED ON      : 09-AUG-2011                                                                                
  *     MODIFIED BY       :                                                                                            
  *     MODIFIED ON       :                                                                                            
  *     VERSION NO        : 1                                                                                          
  */
 BEGIN
  SET @An_Forum_IDNO = NULL;

  DECLARE @Lc_Space_TEXT          CHAR(1)	= ' ',
          @Ld_High_DATE           DATE		= '12/31/9999';
  DECLARE @Ld_SystemDateTime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT DMJR_Y1
         (Case_IDNO,
          OrderSeq_NUMB,
          MajorIntSeq_NUMB,
          MemberMci_IDNO,
          ActivityMajor_CODE,
          Subsystem_CODE,
          TypeOthpSource_CODE,
          OthpSource_IDNO,
          Entered_DATE,
          Status_DATE,
          Status_CODE,
          ReasonStatus_CODE,
          BeginExempt_DATE,
          EndExempt_DATE,
          TotalTopics_QNTY,
          PostLastPoster_IDNO,
          UserLastPoster_ID,
          SubjectLastPoster_TEXT,
          LastPost_DTTM,
          BeginValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          TypeReference_CODE,
          Reference_ID)
  SELECT   @An_Case_IDNO,--Case_IDNO
           @An_OrderSeq_NUMB,--OrderSeq_NUMB
           @An_MajorIntSeq_NUMB,--MajorIntSeq_NUMB
           @An_MemberMci_IDNO,--MemberMci_IDNO
           @Ac_ActivityMajor_CODE,--ActivityMajor_CODE
           @Ac_Subsystem_CODE,--Subsystem_CODE
           @Ac_TypeOthpSource_CODE,--TypeOthpSource_CODE
           @An_OthpSource_IDNO,--OthpSource_IDNO
           @Ld_SystemDateTime_DTTM,--Entered_DATE
           @Ld_High_DATE,--Status_DATE
           @Ac_Status_CODE,--Status_CODE
           @Ac_ReasonStatus_CODE,--ReasonStatus_CODE
           @Ad_BeginExempt_DATE,--BeginExempt_DATE
           @Ad_EndExempt_DATE,--EndExempt_DATE
           @An_TotalTopics_QNTY,--TotalTopics_QNTY
           @An_PostLastPoster_IDNO,--PostLastPoster_IDNO
           @Lc_Space_TEXT,--UserLastPoster_ID
           @As_SubjectLastPoster_TEXT,--SubjectLastPoster_TEXT
           @Ad_LastPost_DTTM,--LastPost_DTTM
           @Ld_SystemDateTime_DTTM,--BeginValidity_DATE
           @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
           @Ld_SystemDateTime_DTTM,--Update_DTTM
           @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
           @Ac_TypeReference_CODE,--TypeReference_CODE
           @Ac_Reference_ID --Reference_ID
          WHERE NOT EXISTS (SELECT 1 
							  FROM DMJR_Y1 A WITH (READUNCOMMITTED ) 
							 WHERE A.Case_IDNO = @An_Case_IDNO 
							   AND A.OrderSeq_NUMB = @An_OrderSeq_NUMB
							   AND A.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB );     

  SELECT @An_Forum_IDNO = SCOPE_IDENTITY();
  
 END; --END OF DMJR_INSERT_S1                                                                                           


GO
