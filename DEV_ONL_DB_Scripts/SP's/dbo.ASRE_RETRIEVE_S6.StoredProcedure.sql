/****** Object:  StoredProcedure [dbo].[ASRE_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ASRE_RETRIEVE_S6] (
 @An_MemberMci_IDNO  NUMERIC(10, 0),
 @Ac_Asset_CODE      CHAR(3),
 @As_Line1Asset_ADDR VARCHAR(50),
 @As_Line2Asset_ADDR VARCHAR(50),
 @Ac_CityAsset_ADDR  CHAR(28),
 @Ac_StateAsset_ADDR CHAR(2),
 @Ac_ZipAsset_ADDR   CHAR(15),
 @Ai_Count_QNTY      INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ASRE_RETRIEVE_S6
  *     DESCRIPTION       : Retrieve the count of records from Realty Assets table for Unique number assigned by the System to the Participants, Type of Asset, First Line of the Asset Street Address, Second Line of the Asset Street Address, City of the Asset Location, State of the Asset Location and Zip of the Asset Location.
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
    FROM ASRE_Y1 A
   WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.Asset_CODE = @Ac_Asset_CODE
     AND A.Line1Asset_ADDR = @As_Line1Asset_ADDR
     AND (@As_Line2Asset_ADDR IS NULL
           OR A.Line2Asset_ADDR = @As_Line2Asset_ADDR)
     AND A.CityAsset_ADDR = @Ac_CityAsset_ADDR
     AND A.StateAsset_ADDR = @Ac_StateAsset_ADDR
     AND A.ZipAsset_ADDR = @Ac_ZipAsset_ADDR
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF ASRE_RETRIEVE_S6

GO
