/****** Object:  StoredProcedure [dbo].[USRT_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRT_RETRIEVE_S12](
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ac_Familial_INDC  CHAR(1) OUTPUT
 )
AS
/*
*     PROCEDURE NAME	: USRT_RETRIEVE_S12
*     DESCRIPTION       : Check if a Case and Member MCI is a Familial Case / Member.
*     DEVELOPED BY      : IMP TEAM
*     DEVELOPED ON      : 25-OCT-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
 BEGIN
  SET @Ac_Familial_INDC = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_Familial_INDC = U.Familial_INDC
    FROM USRT_Y1 U
   WHERE U.MemberMci_IDNO = @An_MemberMci_IDNO
     AND U.Case_IDNO = @An_Case_IDNO
     AND U.End_DATE = @Ld_High_DATE
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END


GO
