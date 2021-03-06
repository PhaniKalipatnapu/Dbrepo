/****** Object:  StoredProcedure [dbo].[CRUDT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
 CREATE PROCEDURE [dbo].[CRUDT_RETRIEVE_S1]
 (
	@An_MemberMci_IDNO			NUMERIC(10,0),
	@Ac_IamUser_ID				CHAR(30)	OUTPUT,
	@Ac_Status_CODE				CHAR(1)		OUTPUT,
	@Ac_Reason_CODE				CHAR(2)		OUTPUT,
	@Ad_LastLogin_DTTM			DATETIME2	OUTPUT,
	@Ac_NoticeTransmission_CODE CHAR(1)		OUTPUT,
	@An_EventGlobalSeq_NUMB NUMERIC(19,0) OUTPUT
 )
 AS
 /*
  *     PROCEDURE NAME    : CRUDT_RETRIEVE_S1
  *     DESCRIPTION       : IT retrieve the Account status and Reason form CRUDT_Y1 ,Last Login from CLHDT_Y1,Form Detail from CNTDT_Y1 based on MemberMci
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
  
 BEGIN
 
	SELECT @Ac_Status_CODE=NULL	,
		@Ac_IamUser_ID=NULL,
		@Ac_Reason_CODE=NULL,
		@Ad_LastLogin_DTTM=NULL,
		@Ac_NoticeTransmission_CODE=NULL,
		@An_EventGlobalSeq_NUMB=NULL;
 
	SELECT @Ac_IamUser_ID=r.IamUser_ID,
		@Ac_Status_CODE=r.Status_CODE,
		@Ac_Reason_CODE=r.Reason_CODE, 
		@Ad_LastLogin_DTTM=l.LastLogin_DTTM,
		@Ac_NoticeTransmission_CODE=n.NoticeTransmission_CODE,
		@An_EventGlobalSeq_NUMB=r.EventGlobalSeq_NUMB
	FROM
		CRUDT_Y1 r 
	LEFT OUTER JOIN 
		CLHDT_Y1 l
	ON
		r.IamUser_ID=l.IamUser_ID
	LEFT OUTER JOIN 
		CNTDT_Y1 n 
	ON
		r.IamUser_ID=n.IamUser_ID
	WHERE r.MemberMci_IDNO=@An_MemberMci_IDNO;

END ;--End of CRUDT_RETRIEVE_S1

GO
