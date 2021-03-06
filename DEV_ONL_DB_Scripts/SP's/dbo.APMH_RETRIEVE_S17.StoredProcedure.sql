/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S17] (
 @An_Application_IDNO NUMERIC(15, 0),
 @An_MemberMci_IDNO   NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : APMH_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve Member History details at the time of Application Received for an Application ID and Member ID when End Validity Date is equal to High Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT A.Begin_DATE,
         A.End_DATE,
         A.TypeWelfare_CODE,
         A.CaseWelfare_IDNO,
         A.WelfareMemberMci_IDNO
    FROM APMH_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APMH_RETRIEVE_S17


GO
