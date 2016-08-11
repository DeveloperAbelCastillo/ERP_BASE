CREATE TABLE [Catalogos].[Personas] (
    [IdPersona]                  [dbo].[Id]          NULL,
    [IdGrupoPersonas]            NCHAR (10)          NULL,
    [cdStatusPersona]            [dbo].[Id]          NULL,
    [cdTipoPersona]              [dbo].[Id]          NULL,
    [LlaveManualPersona]         [dbo].[Llave]       NULL,
    [tNombrePersona]             [dbo].[Descripcion] NULL,
    [IdPais]                     [dbo].[Id]          NULL,
    [IdEstado]                   [dbo].[Id]          NULL,
    [IdMunicipio]                [dbo].[Id]          NULL,
    [IdLocalidad]                [dbo].[Id]          NULL,
    [tCodigoPostal]              [dbo].[Descripcion] NULL,
    [tColonia]                   [dbo].[Descripcion] NULL,
    [tCalle]                     [dbo].[Descripcion] NULL,
    [tNumeroExterior]            [dbo].[Descripcion] NULL,
    [tNumeroInterior]            [dbo].[Descripcion] NULL,
    [tRazonSocial]               [dbo].[Descripcion] NULL,
    [tNombres]                   [dbo].[Descripcion] NULL,
    [tApellidoPaterno]           [dbo].[Descripcion] NULL,
    [tApellidoMaterno]           [dbo].[Descripcion] NULL,
    [tRFC]                       [dbo].[Descripcion] NULL,
    [tCURP]                      [dbo].[Descripcion] NULL,
    [imgFotografia]              [dbo].[Imagen]      NULL,
    [nLatitud]                   [dbo].[Cantidad]    NULL,
    [nAltitud]                   [dbo].[Cantidad]    NULL,
    [nZoomVistaMapa]             [dbo].[Cantidad]    NULL,
    [bCambio]                    [dbo].[SiNo]        NULL,
    [tObservaciones]             [dbo].[TextoLargo]  NULL,
    [IdPersonaHolding]           [dbo].[Id]          NULL,
    [fFechaHoraCreacion]         [dbo].[FechaHora]   NULL,
    [fFechaHoraModificacion]     [dbo].[FechaHora]   NULL,
    [fFechaHoraAutorizacion]     [dbo].[FechaHora]   NULL,
    [UsuarioCreador]             [dbo].[Usuario]     NULL,
    [UsuarioModificacion]        [dbo].[Usuario]     NULL,
    [UsuarioAutorizacion]        [dbo].[Usuario]     NULL,
    [ctCURP]                     AS                  (case when isnull([tCURP],'')='' then CONVERT([nvarchar](10),[IdPersona],(0)) else [tCURP] end),
    [ctNombrePersonaSinEspacios] AS                  (replace(replace(replace([tNombrePersona],' ',''),'.',''),',','')),
    [ctRazonSocial]              AS                  (case when [cdTipoPersona]=(0) then ((([tNombres]+' ')+[tApellidoPaterno])+' ')+[tApellidoMaterno] else [tRazonSocial] end),
    [ctRazonSocialSinEspacios]   AS                  (case when [cdTipoPersona]=(0) then ((replace(replace(replace([tNombres],' ',''),'.',''),',','')+replace(replace(replace([tApellidoPaterno],' ',''),'.',''),',',''))+replace(replace(replace([tApellidoMaterno],' ',''),'.',''),',',''))+replace(replace(replace([tRFC],' ',''),'.',''),',','') else replace(replace(replace([tRazonSocial],' ',''),'.',''),',','') end),
    [ctRFC]                      AS                  (case when isnull([tRFC],'')='' then CONVERT([nvarchar](10),[IdPersona],(0)) else [tRFC] end),
    [LlavePersona]               AS                  (case when isnull([LlaveManualPersona],'')='' then CONVERT([nvarchar](10),[IdPersona],(0)) else [LlaveManualPersona] end)
);


GO
CREATE TRIGGER [Catalogos].[trPersonas]
  ON [Catalogos].[Personas]
   
  AFTER DELETE, INSERT, UPDATE
  AS
Begin

     /* <Resumen>
     **********************************************************************
    
        DESCRIPCION:         
            Esto es para Insertar el Domicilio Fiscal en la tabla de 
            domicilios
         
        PARAMETROS:
            Ninguno

        Creado por:     Abel Castillo
        Fecha:          10 de Agosto de 2016

        Modificado por: Abel Castillo
        Fecha:          10 de Agosto de 2016
     
     **********************************************************************/                        

    Set XACT_ABORT, NOCOUNT ON;
             
    Begin Try
    
        --Siempre inicio una transaccion, con el nombre del procedimiento almacenado.                 
        Begin Transaction trPersonas;
                                
        If Exists (Select * From Inserted) 
        Or Exists (Select * From Deleted)
        Begin
        
            -- Esto es pata Insert Exclusivamente --
            -- If Not Exists (Select * From Deleted)
            -- Begin                            
            
            -- End
            
            -- Esto es para Delete Exclusivamente --
            -- If Not Exists (Select * From Inserted)
            -- Begin
                            

            -- End
                                                               
            -- Esto es para Update Exclusivamente --
            -- If Exists (Select * From Inserted)
            -- And  Exists (Select * From Deleted)
            -- Begin                                                                            
            
            -- End
            
            -- Esto es para Insert o Update --
            If Exists (Select * From Inserted)
            Begin
            
                -- Si no tiene empresa Holding, le pongo el mismo numero de persona
                Update Catalogos.Personas
                Set IdPersonaHolding = A.IdPersona
                From Catalogos.Personas A
                Inner Join Inserted B
                On A.IdPersona = B.IdPersona
                And A.IdPersonaHolding Is Null;
				                            
            End
            
            -- Esto es para Update o Delete --
            -- If Exists (Select * From Deleted)
            -- Begin
                            
            
            -- End
                                    
            -- De aqui en Adelante es para Insert, Update o Delete                                                              
            
        End

        -- Si todo fue correcto confirmo la transaccion                
        Commit;               
       
    End Try
    
    Begin Catch

        IF XACT_STATE() <> 0 
            RollBack;

        Declare @ErrorMessage NVARCHAR(4000);
        Declare @ErrorSeverity INT;
        Declare @ErrorState INT;

        Select 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        
        RaisError (@ErrorMessage, @ErrorSeverity, @ErrorState);

    End Catch

End