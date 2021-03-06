/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S11](
 @An_Application_IDNO NUMERIC(15, 0),
 @Ac_TypeWelfare_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : APMH_RETRIEVE_S11
  *     DESCRIPTION       : Retrieves the Member Id, Welfare Type, Begin Date of the Public Assistance, End Date of the Public Assistance, Welfare Case Id for the given Application Id, Case Welfare Type where Welfare Type is not equal to input Case Welfare Type and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 29-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT A.MemberMci_IDNO,
         A.TypeWelfare_CODE,
         A.Begin_DATE,
         A.End_DATE,
         A.CaseWelfare_IDNO
    FROM APMH_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.TypeWelfare_CODE != @Ac_TypeWelfare_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APMH_RETRIEVE_S11


GO
