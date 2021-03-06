/****** Object:  StoredProcedure [dbo].[UDEM_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UDEM_INSERT_S1](
		@An_MemberMci_IDNO                   NUMERIC(10, 0),
		@An_MemberMciNew_IDNO				 NUMERIC(10, 0),
		@Ac_First_NAME                       CHAR(16),
		@Ac_Last_NAME                        CHAR(20),
		@Ac_Middle_NAME                      CHAR(20),
		@Ac_Suffix_NAME                      CHAR(4),
		@Ad_Birth_DATE                       DATE,
		@Ad_Deceased_DATE                    DATE,
		@An_MemberSsn_NUMB                   NUMERIC(9, 0),
		@Ac_MemberSex_CODE                   CHAR(1),
		@Ac_Race_CODE                        CHAR(1),
		@Ac_TypeUpdate_CODE					 CHAR(2),		
		@Ac_WorkerUpdate_ID                  CHAR(30),
		@An_TransactionEventSeq_NUMB         NUMERIC(19, 0) )
AS
 /*
 *      PROCEDURE NAME    : UDEM_INSERT_S1
  *     DESCRIPTION       : Insert MCI Information in to DemoUpdate Table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 01-JUN-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_No_INDC						CHAR(1) = 'N',
          @Lc_Status_Pending				CHAR(1) = 'P',
		  @Lc_Source_Master_Client_Index	CHAR(3) = 'MCI',
		  @Ld_Low_DATE						DATE    = '01/01/0001',
	      @Ld_Systemdatetime_DTTM			DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT UDEM_Y1
         (  MemberMci_IDNO,
			MemberMciNew_IDNO,
			First_NAME,
			Last_NAME,
			Middle_NAME,
			Suffix_NAME,
			Birth_DATE,
			Deceased_DATE,
			MemberSsn_NUMB,
			MemberSex_CODE,
			Race_CODE,
			TypeUpdate_CODE,
			Source_CODE,
			Received_DATE,
			Completed_DATE,
			Status_CODE,
			FirstNameAcceptance_INDC,
			LastNameAcceptance_INDC,
			MiddleNameAcceptance_INDC,
			SuffixNameAcceptance_INDC,
			BirthDateAcceptance_INDC,
			DeceasedDateAcceptance_INDC,
			MemberSsnAcceptance_INDC,
			MemberSexAcceptance_INDC,
			RaceAcceptance_INDC,
			BeginValidity_DATE,
			Update_DTTM,
			WorkerUpdate_ID,
			TransactionEventSeq_NUMB)
  VALUES ( @An_MemberMci_IDNO,
           @An_MemberMciNew_IDNO,
           @Ac_First_NAME,
           @Ac_Last_NAME,
           @Ac_Middle_NAME,
           @Ac_Suffix_NAME,
           @Ad_Birth_DATE,
           @Ad_Deceased_DATE,
		   @An_MemberSsn_NUMB,
		   @Ac_MemberSex_CODE,
		   @Ac_Race_CODE,
		   @Ac_TypeUpdate_CODE,
		   @Lc_Source_Master_Client_Index,
		   @Ld_Systemdatetime_DTTM,
		   @Ld_Low_DATE,
		   @Lc_Status_Pending,
		   @Lc_No_INDC,
		   @Lc_No_INDC,
		   @Lc_No_INDC,
		   @Lc_No_INDC,
		   @Lc_No_INDC,
		   @Lc_No_INDC,
		   @Lc_No_INDC,
		   @Lc_No_INDC,
		   @Lc_No_INDC,
		   @Ld_Systemdatetime_DTTM,
		   @Ld_Systemdatetime_DTTM,
		   @Ac_WorkerUpdate_ID,
		   @An_TransactionEventSeq_NUMB
		);
 END; -- End Of UDEM_INSERT_S1

GO
