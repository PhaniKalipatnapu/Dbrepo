/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S17]
AS
 /*                                                                                                                                                                                    
 *     PROCEDURE NAME    : AHIS_RETRIEVE_S17                                                                                                                                           
  *     DESCRIPTION       : retrieves the Member Address history details along with the given Application Id, Worker signedOn, Transaction Event sequence where Member Id is '999998'
  *     DEVELOPED BY      : IMP Team                                                                                                                                                 
  *     DEVELOPED ON      : 02-NOV-2011                                                                                                                                                
  *     MODIFIED BY       :                                                                                                                                                            
  *     MODIFIED ON       :                                                                                                                                                            
  *     VERSION NO        : 1                                                                                                                                                          
 */
 BEGIN
  DECLARE @Ln_FosterCaseMemberMci_IDNO NUMERIC(10) = 0000999998;

  SELECT AH.TypeAddress_CODE,
         AH.Line1_ADDR,
         AH.Line2_ADDR,
         AH.City_ADDR,
         AH.State_ADDR,
         AH.Zip_ADDR,
         AH.Attn_ADDR,
         AH.Country_ADDR,
         AH.Normalization_CODE
    FROM AHIS_Y1 AH
   WHERE AH.MemberMci_IDNO = @Ln_FosterCaseMemberMci_IDNO;
 END; --End of AHIS_RETRIEVE_S17


GO
