/****** Object:  StoredProcedure [dbo].[MHIS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_INSERT_S1](
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_Case_IDNO                NUMERIC(6),
 @Ad_Start_DATE               DATE,
 @Ad_End_DATE                 DATE,
 @Ac_TypeWelfare_CODE         CHAR(1),
 @An_CaseWelfare_IDNO         NUMERIC(10),
 @An_WelfareMemberMci_IDNO    NUMERIC(10),
 @Ac_CaseHead_INDC            CHAR(1),
 @Ac_Reason_CODE              CHAR(2),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19)
 )
AS
 DECLARE @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         @Li_Zero_NUMB    SMALLINT = 0;

 /*
 *     PROCEDURE NAME    : MHIS_INSERT_S1
  *     DESCRIPTION       : Insert Member Welfare Details with the provided values.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/03/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  INSERT MHIS_Y1
         (MemberMci_IDNO,
          Case_IDNO,
          Start_DATE,
          End_DATE,
          TypeWelfare_CODE,
          CaseWelfare_IDNO,
          WelfareMemberMci_IDNO,
          CaseHead_INDC,
          Reason_CODE,
          BeginValidity_DATE,
          EventGlobalBeginSeq_NUMB,
          EventGlobalEndSeq_NUMB)
  VALUES ( @An_MemberMci_IDNO,
           @An_Case_IDNO,
           @Ad_Start_DATE,
           @Ad_End_DATE,
           @Ac_TypeWelfare_CODE,
           @An_CaseWelfare_IDNO,
           @An_WelfareMemberMci_IDNO,
           @Ac_CaseHead_INDC,
           @Ac_Reason_CODE,
           @Ld_Current_DATE,
           @An_EventGlobalBeginSeq_NUMB,
           @Li_Zero_NUMB );
 END; --End of MHIS_INSERT_S1


GO
