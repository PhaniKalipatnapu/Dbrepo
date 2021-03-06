/****** Object:  StoredProcedure [dbo].[CNCB_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CNCB_RETRIEVE_S2](    
 @Ad_Transaction_DATE         DATE,    
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),    
 @An_TransHeader_IDNO         NUMERIC(12, 0)    
 )    
AS    
 /*    
 *     PROCEDURE NAME    : CNCB_RETRIEVE_S2    
  *     DESCRIPTION       : Retrieve NCP information like name, date of birth, address information,  phone number and other member information for the Transaction Header Block, State FIPS, Transaction Date in Csennet NCP Block and these should be equal in
  
 Csenet NCP Locate Blocks.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-NOV-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */    
 BEGIN    
       
  DECLARE @Lc_IndInboundOutbound_CODE CHAR(1) = 'I',    
          @Ls_Block_NAME          VARCHAR(50) = 'NCP_DATA_BLOCKS',    
          @Ls_FieldNameEye_NAME       VARCHAR(50) = 'eye_color',    
          @Ls_FieldNameHair_NAME      VARCHAR(50) = 'hair_color';    
    
  SELECT  C.Last_NAME,    
          C.First_NAME,    
          C.Middle_NAME,    
          C.Suffix_NAME,    
          C.MemberSsn_NUMB,    
          C.Birth_DATE,    
          C.Race_CODE,    
          C.MemberSex_CODE,    
          C.PlaceOfBirth_NAME,    
          C.FtHeight_TEXT,    
          C.InHeight_TEXT,    
          ISNULL (C3.InState_CODE,C.ColorHair_CODE) ColorHair_CODE,  
          ISNULL (C2.InState_CODE,C.ColorEyes_CODE) ColorEyes_CODE,  
          C.DistinguishingMarks_TEXT,    
          C.Maiden_NAME,    
          C1.MailingLine1_ADDR,    
          C1.MailingLine2_ADDR,    
          C1.MailingCity_ADDR,    
          C1.MailingState_ADDR,    
          C1.MailingZip_ADDR,
          C1.EmployerEin_ID,
          C1.Employer_NAME,
          C1.EmployerLine1_ADDR,
          C1.EmployerLine2_ADDR,
          C1.EmployerCity_ADDR,
          C1.EmployerZip_ADDR,
          C1.EmployerState_ADDR,
          C1.IVDOutOfStateFips_CODE,
          C1.EmployerPhone_NUMB
    FROM CNCB_Y1  C    
      LEFT OUTER JOIN   
      CSEC_Y1 C2  
       ON (C2.Csenet_CODE = C.ColorEyes_CODE  
        AND C2.Block_NAME = @Ls_Block_NAME    
          AND C2.Field_NAME = @Ls_FieldNameEye_NAME    
          AND C2.InboundOutbound_CODE = @Lc_IndInboundOutbound_CODE)  
         LEFT OUTER JOIN   
        CSEC_Y1 C3  
          ON (C3.Csenet_CODE = C.ColorHair_CODE  
        AND C3.Block_NAME = @Ls_Block_NAME    
          AND C3.Field_NAME = @Ls_FieldNameHair_NAME    
          AND C3.InboundOutbound_CODE = @Lc_IndInboundOutbound_CODE)   
      LEFT OUTER JOIN     
      CNLB_Y1  C1    
    ON (C.TransHeader_IDNO = C1.TransHeader_IDNO AND    
     C.IVDOutOfStateFips_CODE = C1.IVDOutOfStateFips_CODE AND    
     C.Transaction_DATE = C1.Transaction_DATE )    
   WHERE C.TransHeader_IDNO = @An_TransHeader_IDNO    
     AND C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE    
     AND C.Transaction_DATE = @Ad_Transaction_DATE;    
       
 END;--End of CNCB_RETRIEVE_S2    

GO
