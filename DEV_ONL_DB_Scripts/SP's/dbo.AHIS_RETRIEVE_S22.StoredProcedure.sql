/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S22](
 @Ac_TypeAddress_CODE CHAR(1),
 @An_MemberMci_IDNO   NUMERIC(10, 0),
 @Ac_City_ADDR        CHAR(28),
 @Ac_Country_ADDR     CHAR(2),
 @As_Line1_ADDR       VARCHAR(50),
 @As_Line2_ADDR       VARCHAR(50),
 @Ac_State_ADDR       CHAR(2),
 @Ac_Zip_ADDR         CHAR(15),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : AHIS_RETRIEVE_S22
  *     DESCRIPTION       : Retrieve record count of same address in Address History for a Member ID, Address Type, Address Line1, Address Line2, City, State, ZIP and Country.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM AHIS_Y1 A
   WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.TypeAddress_CODE = @Ac_TypeAddress_CODE
     AND A.End_DATE = @Ld_High_DATE
     AND A.Line1_ADDR = @As_Line1_ADDR
     AND A.Line2_ADDR = @As_Line2_ADDR
     AND A.City_ADDR = @Ac_City_ADDR
     AND A.State_ADDR = @Ac_State_ADDR
     AND A.Zip_ADDR = @Ac_Zip_ADDR
     AND A.Country_ADDR = @Ac_Country_ADDR;
	  
 END; --End of AHIS_RETRIEVE_S22


GO
